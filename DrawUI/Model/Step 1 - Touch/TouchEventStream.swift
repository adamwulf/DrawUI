//
//  TouchEventStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 6/28/20.
//

import UIKit

// Processes events for mutiple touches
public class TouchEventStream: Producer {
    // How do I keep Customer generic here?
    public typealias Produces = [TouchEvent]

    // MARK: - Private

    private var recentEvents: [TouchEvent] = []
    private var processedEvents: [TouchEvent] = []
    private var lazyGesture: TouchEventGestureRecognizer?

    // MARK: - Public

    public var events: [TouchEvent] {
        return processedEvents + recentEvents
    }

    // MARK: - Init

    public init() {
        // noop
    }

    // MARK: - Producer<TouchEvent>

    private var consumers: [(process: (Produces) -> Void, reset: () -> Void)] = []

    public func addConsumer<Customer>(_ consumer: Customer) where Customer: Consumer, Customer.Consumes == Produces {
        consumers.append((process: { (produces: Produces) in
            consumer.consume(produces)
        }, reset: consumer.reset))
    }

    public func addConsumer(_ block: @escaping (Produces) -> Void) {
        consumers.append((process: block, reset: {}))
    }

    public func reset() {
        processedEvents = []
        recentEvents = []
        consumers.forEach({ $0.reset() })
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

    // MARK: - Public

    public func process(events: [TouchEvent] = []) {
        processedEvents.append(contentsOf: recentEvents + events)
        defer {
            recentEvents.removeAll()
        }
        consumers.forEach({ $0.process(recentEvents + events) })
    }
}
