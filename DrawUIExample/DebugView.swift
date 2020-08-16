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
    let strokes: Strokes

    override init(frame: CGRect) {
        strokes = Strokes()
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        strokes = Strokes()
        super.init(coder: coder)
    }

    override func draw(_ rect: CGRect) {
        let updatedEvents = touchStream?.process()
        strokes.add(touchEvents: updatedEvents ?? [])

        for event in touchStream?.events ?? [] {
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

        for stroke in strokes.strokes {
            let path = UIBezierPath()
            for point in stroke.points {
                if point.event.phase == .began {
                    path.move(to: point.event.location)
                } else {
                    path.addLine(to: point.event.location)
                }
            }
            path.stroke()
        }
    }
}
