//
//  SmoothStrokePoint.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/17/20.
//

import UIKit

public class SmoothStrokePoint {

    private var point: StrokePoint
    public var event: TouchEvent {
        return point.event
    }
    public var expectsUpdate: Bool {
        return point.expectsUpdate
    }

    public var location: CGPoint

    init(point: StrokePoint) {
        self.point = point
        self.location = point.event.location
    }
}
