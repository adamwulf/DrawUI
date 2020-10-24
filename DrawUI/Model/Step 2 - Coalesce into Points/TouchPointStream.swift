//
//  TouchPointStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit

/// Input: An array of touch events from one or more touches representing one or more strokes.
/// Output: A OrderedTouchPoints for each stroke of touch event data, which coalesces the events into current point data for that stroke
public class TouchPointStream {

    public typealias Output = (pointCollections: [TouchPointCollection], deltas: [Delta])

    public enum Delta {
        case addedTouchPoints(pointCollection: TouchPointCollection)
        case updatedTouchPoints(pointCollection: TouchPointCollection, updatedIndexes: IndexSet)
        case completedTouchPoints(pointCollection: TouchPointCollection)

        public var rawString: String {
            switch self {
            case .addedTouchPoints(let pointCollection):
                return "addedTouchPoints(\(pointCollection.touchIdentifier))"
            case .updatedTouchPoints(let pointCollection, let indexSet):
                return "updatedTouchPoints(\(pointCollection.touchIdentifier), \(indexSet)"
            case .completedTouchPoints(let pointCollection):
                return "completedTouchPoints(\(pointCollection.touchIdentifier))"
            }
        }
    }

    private var touchToPointCollection: [UITouchIdentifier: TouchPointCollection]

    public private(set) var pointCollections: [TouchPointCollection]

    public init() {
        touchToPointCollection = [:]
        pointCollections = []
    }

    @discardableResult
    public func process(touchEvents: [TouchEvent]) -> Output {
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
            if let pointCollection = touchToPointCollection[touchIdentifier] {
                let updatedIndexes = pointCollection.add(touchEvents: events)
                deltas.append(.updatedTouchPoints(pointCollection: pointCollection, updatedIndexes: updatedIndexes))
                if pointCollection.isComplete {
                    deltas.append(.completedTouchPoints(pointCollection: pointCollection))
                }
            } else if let touchIdentifier = events.first?.touchIdentifier,
                      let pointCollection = TouchPointCollection(touchEvents: events) {
                touchToPointCollection[touchIdentifier] = pointCollection
                pointCollections.append(pointCollection)
                deltas.append(.addedTouchPoints(pointCollection: pointCollection))
            }
        }

        return (pointCollections, deltas)
    }
}
