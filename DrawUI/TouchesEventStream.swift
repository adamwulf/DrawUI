//
//  TouchesEventStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 6/28/20.
//

import UIKit

// Processes events for mutiple touches
public class TouchesEventStream: GestureEventStream {
    // MARK: - Private
    public private(set) var events: [TouchEvent] = []
    public private(set) var eventsPerTouch: [String: [TouchEvent]] = [:]
    private var lazyGesture: TouchStreamGestureRecognizer?

    public init() {
        // noop
    }

    @objc func streamChanged(_ gesture: TouchStreamGestureRecognizer) {
        delegate?.touchStreamChanged(self)
    }

    // MARK: - EventStream

    // MARK: - Public
    public var gesture: UIGestureRecognizer {
        lazyGesture = lazyGesture ?? TouchStreamGestureRecognizer(touchStream: self, target: self, action: #selector(streamChanged(_:)))
        return lazyGesture!
    }

    public weak var delegate: EventStreamDelegate?

    public func add(event: TouchEvent) {
        events.append(event)

        if eventsPerTouch[event.touchIdentifier] != nil {
            eventsPerTouch[event.touchIdentifier]?.append(event)
        } else {
            eventsPerTouch[event.touchIdentifier] = [event]
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
