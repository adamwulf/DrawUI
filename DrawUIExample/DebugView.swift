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
    private var deltas: [Strokes.Delta]?

    func add(deltas: [Strokes.Delta]) {
        if self.deltas == nil {
            self.deltas = []
        }
        self.deltas?.append(contentsOf: deltas)
    }

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

        if let deltas = deltas {
            func draw(stroke: Stroke, indexSet: IndexSet?) {
                UIColor.red.setStroke()
                if let indexSet = indexSet {
                    for index in indexSet {
                        if index < stroke.points.count {
                            let point = stroke.points[index]
                            let path = UIBezierPath(arcCenter: point.event.location,
                                                    radius: 4,
                                                    startAngle: 0,
                                                    endAngle: CGFloat(Double.pi * 2),
                                                    clockwise: true)
                            path.stroke()
                        } else {
                            let point = stroke.points.last!
                            UIBezierPath(rect: CGRect(origin: point.event.location, size: CGSize.zero).insetBy(dx: -4, dy: -4)).stroke()
                        }
                    }
                } else {
                    for point in stroke.points {
                        let path = UIBezierPath(arcCenter: point.event.location,
                                                radius: 4,
                                                startAngle: 0,
                                                endAngle: CGFloat(Double.pi * 2),
                                                clockwise: true)
                        path.stroke()
                    }
                }
            }

            for delta in deltas {
                switch delta {
                case .addedStroke(let stroke):
                    draw(stroke: stroke, indexSet: nil)
                case .updatedStroke(let stroke, let indexSet):
                    draw(stroke: stroke, indexSet: indexSet)
                default:
                    break
                }
            }
        }

        deltas?.removeAll()
    }
}
