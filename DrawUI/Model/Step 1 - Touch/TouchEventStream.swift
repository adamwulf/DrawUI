//
//  TouchEventStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 6/28/20.
//

import UIKit

public protocol TouchEventStreamDelegate: class {
    func touchStreamChanged(_ touchStream: TouchEventStream)
}

// Processes events for mutiple touches
public class TouchEventStream {
    // MARK: - Private
    private var recentEvents: [TouchEvent] = []
    private var processedEvents: [TouchEvent] = []
    public var events: [TouchEvent] {
        return processedEvents + recentEvents
    }
    private var lazyGesture: TouchStreamGestureRecognizer?

    public init() {
        // noop
    }

    @objc func streamChanged(_ gesture: TouchStreamGestureRecognizer) {
        delegate?.touchStreamChanged(self)
    }

    // MARK: - GestureEventStream

    public var gesture: UIGestureRecognizer {
        lazyGesture = lazyGesture ?? TouchStreamGestureRecognizer(touchStream: self, target: self, action: #selector(streamChanged(_:)))
        return lazyGesture!
    }

    public weak var delegate: TouchEventStreamDelegate?

    // MARK: - TouchEventStream

    public func add(event: TouchEvent) {
        recentEvents.append(event)
    }

    public func process() -> [TouchEvent] {
        processedEvents.append(contentsOf: recentEvents)
        defer {
            recentEvents.removeAll()
        }
        return recentEvents
    }
}
