//
//  EventStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit

public protocol EventStreamDelegate: class {
    func touchStreamChanged(_ touchStream: EventStream)
}

public protocol EventStream {
    var events: [TouchEvent] { get }
    var eventsPerTouch: [String: [TouchEvent]] { get }

    func add(event: TouchEvent)
    func eventsSince(event: TouchEvent?) -> [TouchEvent]
}

public protocol GestureEventStream: EventStream {
    var delegate: EventStreamDelegate? { get set }
    var gesture: UIGestureRecognizer { get }
}
