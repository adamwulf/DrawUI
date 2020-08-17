//
//  StrokePoint.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/16/20.
//

import Foundation

public class StrokePoint {

    private var events: [TouchEvent]
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
