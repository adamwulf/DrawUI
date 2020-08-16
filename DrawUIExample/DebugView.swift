//
//  DebugView.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit
import DrawUI

class DebugView: UIView {
    var lastSeenEvent: TouchEvent?
    var touchStream: EventStream?

    override init(frame: CGRect) {
        super.init(frame: frame)
//        clearsContextBeforeDrawing = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func draw(_ rect: CGRect) {
        for event in touchStream?.events ?? [] {
            var radius: CGFloat = 2
            if event.isUpdate {
                radius = 1
                if !event.expectsAzimuthUpdate,
                   !event.expectsForceUpdate,
                   !event.expectsLocationUpdate {
                    UIColor.red.setFill()
                } else {
                    UIColor.green.setFill()
                }
            } else if event.isPrediction {
                UIColor.blue.setFill()
            } else {
                if !event.expectsAzimuthUpdate,
                   !event.expectsForceUpdate,
                   !event.expectsLocationUpdate {
                    UIColor.red.setFill()
                } else {
                    UIColor.green.setFill()
                }
            }
            UIBezierPath(ovalIn: CGRect(origin: event.location, size: CGSize.zero).insetBy(dx: -radius, dy: -radius)).fill()
        }

        UIColor.red.setStroke()

        for (_, events) in touchStream?.eventsPerTouch ?? [:] {
            var previousEvent: TouchEvent?
            let path = UIBezierPath()
            path.lineWidth = 0.5
            for event in events {
                if previousEvent != nil {
                    path.addLine(to: event.location)
                } else {
                    path.move(to: event.location)
                }
                previousEvent = event
            }
            path.stroke()
        }
    }
}
