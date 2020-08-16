//
//  TouchStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 6/28/20.
//

import Foundation

public protocol TouchStreamDelegate {
    func touchStreamChanged(_ touchStream: TouchStream)
}

public class TouchStream {
    // MARK: - Private
    private var events: [TouchStreamEvent] = []
    private var eventsPerTouch: [String: [TouchStreamEvent]] = [:]
    private var lazyGesture: TouchStreamGestureRecognizer?

    // MARK: - Public
    public var delegate: TouchStreamDelegate?
    public var gesture: TouchStreamGestureRecognizer {
        lazyGesture = lazyGesture ?? TouchStreamGestureRecognizer(touchStream: self, target: self, action: #selector(streamChanged(_:)))
        return lazyGesture!
    }

    public init() {
        // noop
    }

    @objc func streamChanged(_ gesture: TouchStreamGestureRecognizer) {
        delegate?.touchStreamChanged(self)
    }

    func add(event: TouchStreamEvent) {
        events.append(event)

        if eventsPerTouch[event.touchIdentifier] != nil {
            eventsPerTouch[event.touchIdentifier]?.append(event)
        } else {
            eventsPerTouch[event.touchIdentifier] = [event]
        }
    }

    public func eventsSince(event: TouchStreamEvent?) -> [TouchStreamEvent] {
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

    public func previousEventFor(event: TouchStreamEvent) -> TouchStreamEvent? {
        guard let events = eventsPerTouch[event.touchIdentifier] else { return nil }
        if let index = events.lastIndex(where: { $0 === event }) {
            guard index > 0 else { return nil }

            return events[index - 1]
        } else {
            return eventsPerTouch[event.touchIdentifier]?.last
        }
    }
}
