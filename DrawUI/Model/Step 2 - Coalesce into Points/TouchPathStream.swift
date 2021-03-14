//
//  TouchPathStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit

public protocol TouchPathStreamConsumer {
    func process(_ input: TouchPathStream.Output)
}

private struct AnonymousConsumer: TouchPathStreamConsumer {
    var block: (TouchPathStream.Output) -> Void
    func process(_ input: TouchPathStream.Output) {
        block(input)
    }
}

public protocol TouchPathStreamProducer {
    func addConsumer(_ consumer: TouchPathStreamConsumer)

    func addConsumer(_ block: @escaping (TouchPathStream.Output) -> Void)
}

/// Input: An array of touch events from one or more touches representing one or more collections.
/// A `TouchPathStream` represents all of the different `TouchPathStream.Point` that share the same `touchIdentifier`
/// Output: A OrderedTouchPoints for each stroke of touch event data, which coalesces the events into current point data for that stroke
public class TouchPathStream: TouchEventStreamConsumer, TouchPathStreamProducer {

    public typealias Output = (paths: [TouchPath], deltas: [Delta])

    public enum Delta: Equatable {
        case addedTouchPath(index: Int)
        case updatedTouchPath(index: Int, updatedIndexes: IndexSet)
        case completedTouchPath(index: Int)

        public var rawString: String {
            switch self {
            case .addedTouchPath(let index):
                return "addedTouchPath(\(index))"
            case .updatedTouchPath(let index, let indexSet):
                return "updatedTouchPath(\(index), \(indexSet)"
            case .completedTouchPath(let index):
                return "completedTouchPath(\(index))"
            }
        }
    }

    // MARK: - Private
    private var touchToIndex: [UITouchIdentifier: Int]
    private var consumers: [TouchPathStreamConsumer] = []

    // MARK: - Public
    public private(set) var paths: [TouchPath]

    public init() {
        touchToIndex = [:]
        paths = []
    }

    // MARK: - TouchPathStreamProducer

    public func addConsumer(_ consumer: TouchPathStreamConsumer) {
        consumers.append(consumer)
    }

    public func addConsumer(_ block: @escaping (TouchPathStream.Output) -> Void) {
        addConsumer(AnonymousConsumer(block: block))
    }

    // MARK: - TouchEventStreamConsumer

    public func process(events: [TouchEvent]) {
        var deltas: [Delta] = []
        var orderOfTouches: [UITouchIdentifier] = []
        let updatedEventsPerTouch = events.reduce([:], { (result, event) -> [String: [TouchEvent]] in
            var result = result
            if result[event.touchIdentifier] != nil {
                result[event.touchIdentifier]?.append(event)
            } else {
                result[event.touchIdentifier] = [event]
            }
            if !orderOfTouches.contains(event.touchIdentifier) {
                orderOfTouches.append(event.touchIdentifier)
            }
            return result
        })

        for touchIdentifier in orderOfTouches {
            guard let events = updatedEventsPerTouch[touchIdentifier] else { continue }
            if let index = touchToIndex[touchIdentifier] {
                let path = paths[index]
                let updatedIndexes = path.add(touchEvents: events)
                deltas.append(.updatedTouchPath(index: index, updatedIndexes: updatedIndexes))

                if path.isComplete {
                    deltas.append(.completedTouchPath(index: index))
                }
            } else if let touchIdentifier = events.first?.touchIdentifier,
                      let path = TouchPath(touchEvents: events) {
                let index = paths.count
                touchToIndex[touchIdentifier] = index
                paths.append(path)
                deltas.append(.addedTouchPath(index: index))

                if path.isComplete {
                    deltas.append(.completedTouchPath(index: index))
                }
            }
        }

        let output = (paths, deltas)

        consumers.forEach({ $0.process(output) })
    }
}
