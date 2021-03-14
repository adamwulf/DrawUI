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
    let strokeStream = PolylineStream()
    let pathStream = FlatBezierStream()
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
        touchPathStream.addConsumer(strokeStream)
        strokeStream.addConsumer(douglasPeucker)
        var strokeOutput: PolylineStream.Output = (lines: [], deltas: [])
        strokeStream.addConsumer { (input) in
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

        savitzkyGolay.addConsumer(pathStream)
        pathStream.addConsumer { (input) in
            print("pathCount: \(input.paths.count) updatedCount:\(input.deltas.count)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        debugView?.addGestureRecognizer(touchEventStream.gesture)
    }
}
