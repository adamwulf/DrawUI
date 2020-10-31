//
//  Polyline.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/17/20.
//

import UIKit
import Foundation

public struct Polyline {

    // MARK: - Public Properties
    public let isComplete: Bool
    public let touchIdentifier: String
    public var points: [Point]

    init(touchPoints: TouchPath) {
        isComplete = touchPoints.isComplete
        touchIdentifier = touchPoints.touchIdentifier
        points = touchPoints.points.map({ Point(touchPoint: $0) })
    }

    mutating func update(with stroke: TouchPath, indexSet: IndexSet) -> IndexSet {
        for index in indexSet {
            if index < stroke.points.count {
                if index < points.count {
                    points[index].location = stroke.points[index].event.location
                } else if index == points.count {
                    points.append(Point(touchPoint: stroke.points[index]))
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

extension Polyline {
    /// A mutable version of `TouchPoint` that maintains a reference to the immutable point it's initialized from
    public struct Point {

        // MARK: - Mutable
        public var force: CGFloat
        public var location: CGPoint
        public var altitudeAngle: CGFloat
        public var azimuth: CGFloat

        public var x: CGFloat {
            get {
                location.x
            }
            set {
                location.x = newValue
            }
        }

        public var y: CGFloat {
            get {
                location.y
            }
            set {
                location.y = newValue
            }
        }

        // MARK: - Immutable
        public let touchPoint: TouchPath.Point

        // MARK: - Immutable Computed
        public var event: TouchEvent {
            return touchPoint.event
        }
        public var expectsUpdate: Bool {
            return touchPoint.expectsUpdate
        }

        init(touchPoint: TouchPath.Point) {
            self.force = touchPoint.event.force
            self.location = touchPoint.event.location
            self.altitudeAngle = touchPoint.event.altitudeAngle
            self.azimuth = touchPoint.event.azimuth

            self.touchPoint = touchPoint
        }
    }
}
