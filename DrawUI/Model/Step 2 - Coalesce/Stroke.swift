//
//  Stroke.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/16/20.
//

import Foundation

public class Stroke {
    var touchIdentifier: String

    public private(set) var points: [StrokePoint]
    private var touchToPoint: [String: StrokePoint]

    init?(touchEvents: [TouchEvent]) {
        guard touchEvents.count > 0 else { return nil }
        self.points = []
        self.touchToPoint = [:]
        self.touchIdentifier = touchEvents.first!.touchIdentifier
        add(touchEvents: touchEvents)
    }

    func add(touchEvents: [TouchEvent]) {
        for event in touchEvents {
            if touchToPoint[event.pointIdentifier] != nil {
                touchToPoint[event.pointIdentifier]?.add(event: event)
            } else {
                let point = StrokePoint(event: event)
                touchToPoint[event.pointIdentifier] = point
                points.append(point)
            }
        }
    }
}

extension Stroke: Hashable {
    public static func == (lhs: Stroke, rhs: Stroke) -> Bool {
        return lhs.touchIdentifier == rhs.touchIdentifier
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(touchIdentifier)
    }
}
