//
//  DebugView.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit
import DrawUI

class DebugView: UIView {
    var strokes: Strokes?

    override func draw(_ rect: CGRect) {
        for event in strokes?.touchStream.events ?? [] {
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

        for stroke in strokes?.strokes ?? [] {
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
