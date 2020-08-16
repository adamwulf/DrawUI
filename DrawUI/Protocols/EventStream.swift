//
//  EventStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/16/20.
//

import Foundation

public protocol EventStreamDelegate: class {
    func touchStreamChanged(_ touchStream: EventStream)
}

public protocol EventStream {
    var delegate: EventStreamDelegate? { get set }
    var gesture: TouchStreamGestureRecognizer { get }

    var events: [TouchEvent] { get }
    var eventsPerTouch: [String: [TouchEvent]] { get }

    func add(event: TouchEvent)
    func eventsSince(event: TouchEvent?) -> [TouchEvent]
}
