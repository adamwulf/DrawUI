//
//  TouchEventStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 6/28/20.
//

import UIKit

// Processes events for mutiple touches
public class TouchEventStream {
    // MARK: - Private
    private var recentEvents: [TouchEvent] = []
    private var processedEvents: [TouchEvent] = []

    // MARK: - Public
    public var eventStreamChanged: ((_ events: [TouchEvent]) -> Void)? {
        didSet {
            print("did set")
        }
    }
    public var events: [TouchEvent] {
        return processedEvents + recentEvents
    }

    public init() {
        // noop
    }

    // MARK: - Gesture

    @objc private func gestureDidTouch(_ gesture: TouchStreamGestureRecognizer) {
        eventStreamChanged?(self.process())
    }

    // MARK: - GestureEventStream

    private var lazyGesture: TouchStreamGestureRecognizer?
    public var gesture: UIGestureRecognizer {
        lazyGesture = lazyGesture ?? TouchStreamGestureRecognizer(touchStream: self, target: self, action: #selector(gestureDidTouch(_:)))
        return lazyGesture!
    }

    // MARK: - TouchEventStream

    public func add(event: TouchEvent) {
        recentEvents.append(event)
    }

    private func process() -> [TouchEvent] {
        processedEvents.append(contentsOf: recentEvents)
        defer {
            recentEvents.removeAll()
        }
        return recentEvents
    }
}
