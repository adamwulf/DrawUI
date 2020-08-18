//
//  StrokeStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/17/20.
//

import UIKit

public protocol StrokeStreamDelegate: class {
    func strokesChanged(_ strokes: [Stroke], deltas: [StrokeStream.Delta])
}

public class StrokeStream {

    public enum Delta {
        case addedSmoothStroke(stroke: Int)
        case updatedSmoothStroke(stroke: Int, updatedIndexes: IndexSet)
        case completedSmoothStroke(stroke: Int)

        public var rawString: String {
            switch self {
            case .addedSmoothStroke(let stroke):
                return "addedSmoothStroke(\(stroke))"
            case .updatedSmoothStroke(let stroke, let indexSet):
                return "updatedSmoothStroke(\(stroke), \(indexSet)"
            case .completedSmoothStroke(let stroke):
                return "completedSmoothStroke(\(stroke))"
            }
        }
    }

    public private(set) var strokes: [Stroke]
    public private(set) var otpToIndex: [OrderedTouchPoints: Int]
    public weak var delegate: StrokeStreamDelegate?
    public var gesture: UIGestureRecognizer {
        return strokeStream.gesture
    }
    public var touchStream: TouchEventStream {
        return strokeStream.touchStream
    }
    public let strokeStream = TouchPointStream()

    public init() {
        otpToIndex = [:]
        strokes = []
        strokeStream.delegate = self
    }

    @discardableResult
    public func add(touchEvents: [TouchPointStream.Delta]) -> [Delta] {
        var deltas: [Delta] = []

        for delta in touchEvents {
            switch delta {
            case .addedStroke(let stroke):
                let smoothStroke = Stroke(touchPoints: stroke)
                let index = strokes.count
                otpToIndex[stroke] = index
                strokes.append(smoothStroke)
                deltas.append(.addedSmoothStroke(stroke: index))
            case .updatedStroke(let stroke, let indexSet):
                if let index = otpToIndex[stroke] {
                    let updates = strokes[index].update(with: stroke, indexSet: indexSet)
                    deltas.append(.updatedSmoothStroke(stroke: index, updatedIndexes: updates))
                }
            case .completedStroke(let stroke):
                if let index = otpToIndex[stroke] {
                    deltas.append(.completedSmoothStroke(stroke: index))
                }
                break
            }
        }

        return deltas
    }
}

extension StrokeStream: TouchPointStreamDelegate {
    public func strokesChanged(_ strokes: [OrderedTouchPoints], deltas: [TouchPointStream.Delta]) {
        // TODO: update the smooth strokes given the updates to the underlying strokes
        let updates = self.add(touchEvents: deltas)

        self.delegate?.strokesChanged(self.strokes, deltas: updates)
    }
}
