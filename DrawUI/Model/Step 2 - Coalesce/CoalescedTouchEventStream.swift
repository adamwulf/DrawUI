//
//  CoalescedTouchEventStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit

/// Input: An array of touch events from one or more touches representing one or more strokes.
/// Output: A OrderedTouchPoints for each stroke of touch event data, which coalesces the events into current point data for that stroke
public class CoalescedTouchEventStream {

    public typealias Output = (strokePoints: [CoalescedTouchEvents], deltas: [Delta])

    public enum Delta {
        case addedTouchPoints(stroke: CoalescedTouchEvents)
        case updatedTouchPoints(stroke: CoalescedTouchEvents, updatedIndexes: IndexSet)
        case completedTouchPoints(stroke: CoalescedTouchEvents)

        public var rawString: String {
            switch self {
            case .addedTouchPoints(let stroke):
                return "addedTouchPoints(\(stroke.touchIdentifier))"
            case .updatedTouchPoints(let stroke, let indexSet):
                return "updatedTouchPoints(\(stroke.touchIdentifier), \(indexSet)"
            case .completedTouchPoints(let stroke):
                return "completedTouchPoints(\(stroke.touchIdentifier))"
            }
        }
    }

    private var touchToStroke: [UITouchIdentifier: CoalescedTouchEvents]

    public private(set) var strokes: [CoalescedTouchEvents]

    public init() {
        touchToStroke = [:]
        strokes = []
    }

    @discardableResult
    public func add(touchEvents: [TouchEvent]) -> Output {
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
                deltas.append(.updatedTouchPoints(stroke: stroke, updatedIndexes: updatedIndexes))
                if stroke.isComplete {
                    deltas.append(.completedTouchPoints(stroke: stroke))
                }
            } else if let touchIdentifier = events.first?.touchIdentifier,
                      let stroke = CoalescedTouchEvents(touchEvents: events) {
                touchToStroke[touchIdentifier] = stroke
                strokes.append(stroke)
                deltas.append(.addedTouchPoints(stroke: stroke))
            }
        }

        return (strokes, deltas)
    }
}
