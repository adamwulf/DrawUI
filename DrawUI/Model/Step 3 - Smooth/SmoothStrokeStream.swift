//
//  StrokeStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/17/20.
//

import UIKit

public protocol SmoothStrokeStreamDelegate: class {
    func strokesChanged(_ strokes: StrokeStream, deltas: [StrokeStream.Delta])
}

public class StrokeStream {

    public enum Delta {
        case addedSmoothStroke(stroke: Stroke)
        case updatedSmoothStroke(stroke: Stroke, updatedIndexes: IndexSet)
        case completedSmoothStroke(stroke: Stroke)

        public var rawString: String {
            switch self {
            case .addedSmoothStroke(let stroke):
                return "addedSmoothStroke(\(stroke.touchIdentifier))"
            case .updatedSmoothStroke(let stroke, let indexSet):
                return "updatedSmoothStroke(\(stroke.touchIdentifier), \(indexSet)"
            case .completedSmoothStroke(let stroke):
                return "completedSmoothStroke(\(stroke.touchIdentifier))"
            }
        }
    }

    public private(set) var strokes: [Stroke]
    public private(set) var strokeToStroke: [OrderedTouchPoints: Stroke]
    public weak var delegate: SmoothStrokeStreamDelegate?
    public var gesture: UIGestureRecognizer {
        return strokeStream.gesture
    }
    public var touchStream: TouchEventStream {
        return strokeStream.touchStream
    }
    public let strokeStream = TouchPointStream()

    public init() {
        strokeToStroke = [:]
        strokes = []
        strokeStream.delegate = self
    }

    @discardableResult
    public func add(touchEvents: [TouchPointStream.Delta]) -> [Delta] {
        var deltas: [Delta] = []

        for delta in touchEvents {
            switch delta {
            case .addedStroke(let stroke):
                let smoothStroke = Stroke(stroke: stroke)
                strokeToStroke[stroke] = smoothStroke
                strokes.append(smoothStroke)
                deltas.append(.addedSmoothStroke(stroke: smoothStroke))
            case .updatedStroke(let stroke, let indexSet):
                if let smoothStroke = strokeToStroke[stroke] {
                    let updates = smoothStroke.update(with: stroke, indexSet: indexSet)
                    deltas.append(.updatedSmoothStroke(stroke: smoothStroke, updatedIndexes: updates))
                }
            case .completedStroke(let stroke):
                if let smoothStroke = strokeToStroke[stroke] {
                    deltas.append(.completedSmoothStroke(stroke: smoothStroke))
                }
            }
        }

        return deltas
    }
}

extension StrokeStream: TouchPointStreamDelegate {
    public func strokesChanged(_ strokes: [OrderedTouchPoints], deltas: [TouchPointStream.Delta]) {
        // TODO: update the smooth strokes given the updates to the underlying strokes
        let updates = self.add(touchEvents: deltas)

        self.delegate?.strokesChanged(self, deltas: updates)
    }
}
