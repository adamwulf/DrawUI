//
//  TouchPointStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit

/// Input: An array of touch events from one or more touches representing one or more collections.
/// A `TouchPointCollection` represents all of the different TouchPoints that share the same `touchIdentifier`
/// Output: A OrderedTouchPoints for each stroke of touch event data, which coalesces the events into current point data for that stroke
public class TouchPointStream {

    public typealias Output = (pointCollections: [TouchPointCollection], deltas: [Delta])

    public enum Delta {
        case addedTouchPoints(pointCollectionIndex: Int)
        case updatedTouchPoints(pointCollectionIndex: Int, updatedIndexes: IndexSet)
        case completedTouchPoints(pointCollectionIndex: Int)

        public var rawString: String {
            switch self {
            case .addedTouchPoints(let pointCollectionIndex):
                return "addedTouchPoints(\(pointCollectionIndex))"
            case .updatedTouchPoints(let pointCollectionIndex, let indexSet):
                return "updatedTouchPoints(\(pointCollectionIndex), \(indexSet)"
            case .completedTouchPoints(let pointCollectionIndex):
                return "completedTouchPoints(\(pointCollectionIndex))"
            }
        }
    }

    private var touchToIndex: [UITouchIdentifier: Int]
    public private(set) var pointCollections: [TouchPointCollection]

    public init() {
        touchToIndex = [:]
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
            if let pointCollectionIndex = touchToIndex[touchIdentifier] {
                let pointCollection = pointCollections[pointCollectionIndex]
                let updatedIndexes = pointCollection.add(touchEvents: events)
                deltas.append(.updatedTouchPoints(pointCollectionIndex: pointCollectionIndex, updatedIndexes: updatedIndexes))

                if pointCollection.isComplete {
                    deltas.append(.completedTouchPoints(pointCollectionIndex: pointCollectionIndex))
                }
            } else if let touchIdentifier = events.first?.touchIdentifier,
                      let pointCollection = TouchPointCollection(touchEvents: events) {
                let pointCollectionIndex = pointCollections.count
                touchToIndex[touchIdentifier] = pointCollectionIndex
                pointCollections.append(pointCollection)
                deltas.append(.addedTouchPoints(pointCollectionIndex: pointCollectionIndex))
            }
        }

        return (pointCollections, deltas)
    }
}
