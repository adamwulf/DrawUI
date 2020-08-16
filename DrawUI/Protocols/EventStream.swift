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
    var delegate: EventStreamDelegate? { get set }
    var gesture: UIGestureRecognizer { get }
    var events: [TouchEvent] { get }

    func add(event: TouchEvent)
    func process() -> [TouchEvent]
}
