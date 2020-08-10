//
//  MMPen.swift
//  DrawUI
//
//  Created by Adam Wulf on 6/28/20.
//

import UIKit

public class Pen {

    var minSize: CGFloat {
        didSet {
            minSize = max(1, minSize)
        }
    }
    var maxSize: CGFloat {
        didSet {
            minSize = max(1, minSize)
        }
    }
    let color: UIColor?

    /**
     * the velocity of the last touch, between 0 and 1
     *
     * a value of 0 means the pen is moving less than or equal to
     * the TouchVelocityGestureRecognizer.MIN
     * a value of 1 means the pen is moving faster than or equal to
     * the TouchVelocityGestureRecognizer.MAX
     **/
    var velocity: CGFloat = 0
    var shouldUseVelcity = true

    private var lastWidth: CGFloat
    private var shortStrokeEnding: Bool = false

    public init(minSize: CGFloat, maxSize: CGFloat, color: UIColor?) {
        self.minSize = minSize
        self.maxSize = maxSize
        self.color = color
        lastWidth = 0
    }

    func willBegin(stroke: DrawnStroke, with event: TouchStreamEvent) -> Bool {
        shortStrokeEnding = false
        velocity = 1
        return true
    }

    func willMove(stroke: DrawnStroke, with event: TouchStreamEvent) {
        velocity = event.velocity
    }

    func willEnd(storke: DrawnStroke, with event: TouchStreamEvent, shortStrokeEnding: Bool) {
        self.shortStrokeEnding = shortStrokeEnding
    }

    func width(for event: TouchStreamEvent) -> CGFloat {
        if event.type == .stylus {
            var width = (maxSize + minSize) / 2.0
            width *= event.force
            if width < minSize {
                width = minSize
            } else if width > maxSize {
                width = maxSize
            }
            return width
        } else if shouldUseVelcity {
            var width = velocity - 1
            if width > 0 {
                width = 0
            }
            width = minSize + (maxSize - minSize) * abs(width)
            if width < minSize {
                width = minSize
            }
            if shortStrokeEnding {
                return maxSize
            }
            if lastWidth != 0 {
                let threshold: CGFloat = 0.5
                if width - lastWidth > threshold {
                    width = lastWidth + threshold
                } else if width - lastWidth < -2.0 * threshold {
                    width = lastWidth - 2.0 * threshold
                }
            }
            lastWidth = width
            return width
        } else {
            let width = minSize + (maxSize - minSize) * event.force
            return max(minSize, min(maxSize, width))
        }
    }

    func smoothness(for event: TouchStreamEvent) -> CGFloat {
        return 0.75
    }
}
