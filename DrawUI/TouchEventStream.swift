//
//  TouchEventStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit

// proceses events for a single touch
public class TouchEventStream: EventStream {
    // MARK: - Private
    private let touchIdentifier: String
    public private(set) var events: [TouchEvent] = []
    public private(set) var eventsPerTouch: [String: [TouchEvent]] = [:]
    private var lazyGesture: TouchStreamGestureRecognizer?

    private var phase: UITouch.Phase
    private var eventsExpectingUpdate: [NSNumber: TouchEvent]

    public var isFinished: Bool {
        return (phase == .ended || phase == .cancelled) && eventsExpectingUpdate.isEmpty
    }

    public init(event: TouchEvent) {
        events.append(event)
        touchIdentifier = event.touchIdentifier
        phase = event.phase
        eventsExpectingUpdate = [:]
    }

    // MARK: - EventStream

    public func add(event: TouchEvent) {
        guard touchIdentifier == event.touchIdentifier else {
            assertionFailure("Touch stream for \(touchIdentifier) cannot process event for \(event.touchIdentifier)")
            return
        }
        events.append(event)

        if eventsPerTouch[event.touchIdentifier] != nil {
            eventsPerTouch[event.touchIdentifier]?.append(event)
        } else {
            eventsPerTouch[event.touchIdentifier] = [event]
        }

        if let updateIndex = event.estimationUpdateIndex {
            if event.expectsUpdate {
                eventsExpectingUpdate[updateIndex] = event
            } else {
                eventsExpectingUpdate.removeValue(forKey: updateIndex)
            }
        }
    }

    public func eventsSince(event: TouchEvent?) -> [TouchEvent] {
        guard let event = event else { return events }

        let loc = events.lastIndex { (e) -> Bool in
            return e === event
        }

        guard let index = loc else { return events }

        if index < events.count - 1 {
            return Array(events.suffix(from: index + 1))
        } else {
            return []
        }
    }
}
