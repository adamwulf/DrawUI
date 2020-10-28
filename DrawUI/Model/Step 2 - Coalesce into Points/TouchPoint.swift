//
//  TouchPoint.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/16/20.
//

import Foundation

public class TouchPoint {

    public private(set) var events: [TouchEvent]
    public var event: TouchEvent {
        return events.last!
    }
    public var expectsUpdate: Bool {
        return self.event.isPrediction || self.event.expectsUpdate
    }

    init(event: TouchEvent) {
        events = [event]
    }

    func add(event: TouchEvent) {
        events.append(event)
    }
}

extension TouchPoint: Hashable {
    public static func == (lhs: TouchPoint, rhs: TouchPoint) -> Bool {
        return lhs.expectsUpdate == rhs.expectsUpdate && lhs.events == rhs.events
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(events)
    }
}
