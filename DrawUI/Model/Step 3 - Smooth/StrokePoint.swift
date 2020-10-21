//
//  StrokePoint.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/17/20.
//

import UIKit

public struct StrokePoint {

    // MARK: - Mutable
    public var force: CGFloat
    public var location: CGPoint
    public var altitudeAngle: CGFloat
    public var azimuth: CGFloat

    // MARK: - Immutable
    public let touchPoint: CoalescedTouchEvent

    // MARK: - Immutable Computed
    public var event: TouchEvent {
        return touchPoint.event
    }
    public var expectsUpdate: Bool {
        return touchPoint.expectsUpdate
    }

    init(touchPoint: CoalescedTouchEvent) {
        self.force = touchPoint.event.force
        self.location = touchPoint.event.location
        self.altitudeAngle = touchPoint.event.altitudeAngle
        self.azimuth = touchPoint.event.azimuth

        self.touchPoint = touchPoint
    }
}
