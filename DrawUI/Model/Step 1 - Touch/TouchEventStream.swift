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
    private var lazyGesture: TouchStreamGestureRecognizer?

    // MARK: - Public
    public var eventStreamChanged: ((_ events: [TouchEvent]) -> Void)?
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

    public var gesture: UIGestureRecognizer {
        lazyGesture = lazyGesture ?? TouchStreamGestureRecognizer(target: self, action: #selector(gestureDidTouch(_:)))
        lazyGesture?.callback = { [weak self] touchEvents in
            self?.recentEvents.append(contentsOf: touchEvents)
        }
        return lazyGesture!
    }

    // MARK: - TouchEventStream

    private func process() -> [TouchEvent] {
        processedEvents.append(contentsOf: recentEvents)
        defer {
            recentEvents.removeAll()
        }
        return recentEvents
    }
}
