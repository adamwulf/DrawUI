//
//  TouchEventStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 6/28/20.
//

import UIKit

public protocol TouchEventStreamConsumer {
    func process(events: [TouchEvent])
}

private struct AnonymousConsumer: TouchEventStreamConsumer {
    var block: ([TouchEvent]) -> Void
    func process(events: [TouchEvent]) {
        block(events)
    }
}

// Processes events for mutiple touches
public class TouchEventStream {

    // MARK: - Private
    private var recentEvents: [TouchEvent] = []
    private var processedEvents: [TouchEvent] = []
    private var lazyGesture: TouchEventGestureRecognizer?
    private var consumers: [TouchEventStreamConsumer] = []

    // MARK: - Public
    public var events: [TouchEvent] {
        return processedEvents + recentEvents
    }

    public init() {
        // noop
    }

    // MARK: - Consumers

    public func addConsumer(_ consumer: TouchEventStreamConsumer) {
        consumers.append(consumer)
    }

    public func addConsumer(_ block: @escaping ([TouchEvent]) -> Void) {
        addConsumer(AnonymousConsumer(block: block))
    }

    // MARK: - Gesture

    @objc private func gestureDidTouch(_ gesture: TouchEventGestureRecognizer) {
        self.process()
    }

    // MARK: - GestureEventStream

    public var gesture: UIGestureRecognizer {
        lazyGesture = lazyGesture ?? TouchEventGestureRecognizer(target: self, action: #selector(gestureDidTouch(_:)))
        lazyGesture?.callback = { [weak self] touchEvents in
            self?.recentEvents.append(contentsOf: touchEvents)
        }
        return lazyGesture!
    }

    // MARK: - TouchEventStream

    private func process() {
        processedEvents.append(contentsOf: recentEvents)
        defer {
            recentEvents.removeAll()
        }
        consumers.forEach({ $0.process(events: recentEvents) })
    }
}
