//
//  Stroke.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/17/20.
//

import Foundation

public struct Stroke {
    // MARK: - Public Properties
    public let isComplete: Bool
    public let touchIdentifier: String
    public var points: [StrokePoint]

    init(touchPoints: OrderedTouchPoints) {
        isComplete = touchPoints.isComplete
        touchIdentifier = touchPoints.touchIdentifier
        points = touchPoints.points.map({ StrokePoint(touchPoint: $0) })
    }

    mutating func update(with stroke: OrderedTouchPoints, indexSet: IndexSet) -> IndexSet {
        for index in indexSet {
            if index < stroke.points.count {
                if index < points.count {
                    points[index].location = stroke.points[index].event.location
                } else if index == points.count {
                    points.append(StrokePoint(touchPoint: stroke.points[index]))
                } else {
                    assertionFailure("Attempting to modify a point that doesn't yet exist. maybe an update is out of order?")
                }
            } else {
                points.remove(at: index)
            }
        }
        return indexSet
    }
}
