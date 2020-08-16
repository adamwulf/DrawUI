//
//  TouchStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 6/28/20.
//

import Foundation

public class TouchStream {
    private var events: [TouchStreamEvent] = []

    func add(event: TouchStreamEvent) {
        events.append(event)
    }

    func eventsSince(event: TouchStreamEvent?) -> [TouchStreamEvent] {
        guard let event = event else { return events }

        let loc = events.lastIndex { (e) -> Bool in
            return e === event
        }

        guard let index = loc else { return events }

        if index < events.count - 1 {
            return Array(events.suffix(from: index + 1))
        } else {
            return []
        }
    }
}
