//
//  TouchPointStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit

public protocol TouchPointStreamDelegate: class {
    func strokesChanged(_ strokes: [OrderedTouchPoints], deltas: [TouchPointStream.Delta])
}

public class TouchPointStream {

    public enum Delta {
        case addedStroke(stroke: OrderedTouchPoints)
        case updatedStroke(stroke: OrderedTouchPoints, updatedIndexes: IndexSet)
        case completedStroke(stroke: OrderedTouchPoints)

        public var rawString: String {
            switch self {
            case .addedStroke(let stroke):
                return "addedStroke(\(stroke.touchIdentifier))"
            case .updatedStroke(let stroke, let indexSet):
                return "updatedStroke(\(stroke.touchIdentifier), \(indexSet)"
            case .completedStroke(let stroke):
                return "completedStroke(\(stroke.touchIdentifier))"
            }
        }
    }

    private var touchToStroke: [UITouchIdentifier: OrderedTouchPoints]

    public private(set) var strokes: [OrderedTouchPoints]
    public weak var delegate: TouchPointStreamDelegate?
    public var gesture: UIGestureRecognizer {
        return touchStream.gesture
    }

    public let touchStream = TouchEventStream()

    public init() {
        touchToStroke = [:]
        strokes = []
        touchStream.delegate = self
    }

    @discardableResult
    public func add(touchEvents: [TouchEvent]) -> [Delta] {
        var deltas: [Delta] = []
        let updatedEventsPerTouch = touchEvents.reduce([:], { (result, event) -> [String: [TouchEvent]] in
            var result = result
            if result[event.touchIdentifier] != nil {
                result[event.touchIdentifier]?.append(event)
            } else {
                result[event.touchIdentifier] = [event]
            }
            return result
        })

        for (touchIdentifier, events) in updatedEventsPerTouch {
            if let stroke = touchToStroke[touchIdentifier] {
                let updatedIndexes = stroke.add(touchEvents: events)
                deltas.append(.updatedStroke(stroke: stroke, updatedIndexes: updatedIndexes))
                if stroke.isComplete {
                    deltas.append(.completedStroke(stroke: stroke))
                }
            } else if let touchIdentifier = events.first?.touchIdentifier,
                      let stroke = OrderedTouchPoints(touchEvents: events) {
                touchToStroke[touchIdentifier] = stroke
                strokes.append(stroke)
                deltas.append(.addedStroke(stroke: stroke))
            }
        }

        return deltas
    }
}

extension TouchPointStream: TouchEventStreamDelegate {
    public func touchStreamChanged(_ touchStream: TouchEventStream) {
        let updatedEvents = touchStream.process()
        let updates = self.add(touchEvents: updatedEvents)

        delegate?.strokesChanged(strokes, deltas: updates)
    }
}
