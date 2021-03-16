//
//  DebugViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit
import DrawUI

class DebugViewController: BaseViewController {

    let touchPathStream = TouchPathStream()
    let lineStream = PolylineStream()
    let bezierStream = FlatBezierStream()
    @IBOutlet var debugView: DebugView!

    let savitzkyGolay = NaiveSavitzkyGolay()
    let douglasPeucker = NaiveDouglasPeucker()
    let pointDistance = NaivePointDistance()

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        touchEventStream.addConsumer { (updatedEvents) in
            self.allEvents.append(contentsOf: updatedEvents)
        }
        touchEventStream.addConsumer(touchPathStream)
        touchPathStream.addConsumer(lineStream)
        lineStream.addConsumer(douglasPeucker)
        var strokeOutput: PolylineStream.Produces = (lines: [], deltas: [])
        lineStream.addConsumer { (input) in
            strokeOutput = input
        }
        douglasPeucker.addConsumer(pointDistance)
        pointDistance.addConsumer(savitzkyGolay)
        savitzkyGolay.addConsumer { (smoothOutput) in
            self.debugView?.originalStrokes = strokeOutput.lines
            self.debugView?.smoothStrokes = smoothOutput.lines
            self.debugView?.add(deltas: strokeOutput.deltas)
            self.debugView?.setNeedsDisplay()
        }

        savitzkyGolay.addConsumer(bezierStream)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        debugView?.addGestureRecognizer(touchEventStream.gesture)
    }
}
