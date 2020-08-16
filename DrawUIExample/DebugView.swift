//
//  DebugView.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit
import DrawUI

class DebugView: UIView {
    var touchStream: EventStream?

    override init(frame: CGRect) {
        super.init(frame: frame)
        clearsContextBeforeDrawing = false
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        clearsContextBeforeDrawing = false
    }

    override func draw(_ rect: CGRect) {
        let updatedEvents = touchStream?.process()
        let updatedEventsPerTouch = updatedEvents?.reduce([:], { (result, event) -> [String: [TouchEvent]] in
            var result = result
            if result[event.touchIdentifier] != nil {
                result[event.touchIdentifier]?.append(event)
            } else {
                result[event.touchIdentifier] = [event]
            }
            return result
        }) ?? [:]

        for event in updatedEvents ?? [] {
            var radius: CGFloat = 2
            if event.isUpdate {
                radius = 1
                if !event.expectsUpdate {
                    UIColor.red.setFill()
                } else {
                    UIColor.green.setFill()
                }
            } else if event.isPrediction {
                UIColor.blue.setFill()
            } else {
                if !event.expectsUpdate {
                    UIColor.red.setFill()
                } else {
                    UIColor.green.setFill()
                }
            }
            UIBezierPath(ovalIn: CGRect(origin: event.location, size: CGSize.zero).insetBy(dx: -radius, dy: -radius)).fill()
        }

        UIColor.red.setStroke()

        for touchIdentifier in updatedEventsPerTouch.keys {

        }

        for (_, events) in updatedEventsPerTouch {
            var previousEvent: TouchEvent?
            let path = UIBezierPath()
            path.lineWidth = 0.5
            for event in events {
                if !event.expectsUpdate,
                   !event.isPrediction {
                    if previousEvent != nil {
                        path.addLine(to: event.location)
                    } else {
                        path.move(to: event.location)
                    }
                    previousEvent = event
                }
            }
            path.stroke()
        }
    }
}
