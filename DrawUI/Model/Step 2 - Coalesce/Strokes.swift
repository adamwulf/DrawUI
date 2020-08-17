//
//  Strokes.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/16/20.
//

import Foundation

public class Strokes {
    public private(set) var strokes: [Stroke]
    public private(set) var touchToStroke: [String: Stroke]

    public init() {
        touchToStroke = [:]
        strokes = []
    }

    @discardableResult
    public func add(touchEvents: [TouchEvent]) -> [Stroke] {
        var modifiedStrokes: Set<Stroke> = Set()
        let updatedEventsPerTouch = touchEvents.reduce([:], { (result, event) -> [String: [TouchEvent]] in
            var result = result
            if result[event.touchIdentifier] != nil {
                result[event.touchIdentifier]?.append(event)
            } else {
                result[event.touchIdentifier] = [event]
            }
            return result
        })

        for (touchIdentifier, events) in updatedEventsPerTouch {
            if let stroke = touchToStroke[touchIdentifier] {
                stroke.add(touchEvents: events)
                modifiedStrokes.insert(stroke)
            } else if let touchIdentifier = events.first?.touchIdentifier,
                      let stroke = Stroke(touchEvents: events) {
                touchToStroke[touchIdentifier] = stroke
                strokes.append(stroke)
                modifiedStrokes.insert(stroke)
            }
        }

        return Array(modifiedStrokes)
    }
}
