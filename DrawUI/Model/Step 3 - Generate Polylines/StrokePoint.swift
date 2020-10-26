//
//  StrokePoint.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/17/20.
//

import UIKit

/// A mutable version of `TouchPoint` that maintains a reference to the immutable point it's initialized from
public struct StrokePoint {

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
    public let touchPoint: TouchPoint

    // MARK: - Immutable Computed
    public var event: TouchEvent {
        return touchPoint.event
    }
    public var expectsUpdate: Bool {
        return touchPoint.expectsUpdate
    }

    init(touchPoint: TouchPoint) {
        self.force = touchPoint.event.force
        self.location = touchPoint.event.location
        self.altitudeAngle = touchPoint.event.altitudeAngle
        self.azimuth = touchPoint.event.azimuth

        self.touchPoint = touchPoint
    }
}
