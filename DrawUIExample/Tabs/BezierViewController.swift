//
//  BezierViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 3/14/21.
//

import UIKit
import DrawUI
import MMSwiftToolbox

class BezierViewController: BaseViewController {

    let touchPathStream = TouchPathStream()
    let lineStream = PolylineStream()
    let savitzkyGolay = NaiveSavitzkyGolay()
    let bezierStream = BezierStream(smoother: AntigrainSmoother())
    let attributeStream = AttributesStream()
    @IBOutlet var pathView: SmartDrawRectView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        touchEventStream.addConsumer(touchPathStream)
        touchPathStream.addConsumer(lineStream)
        lineStream.addConsumer(savitzkyGolay)
        savitzkyGolay.addConsumer(bezierStream)
        bezierStream.addConsumer(attributeStream)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        attributeStream.addConsumer(pathView)
        pathView?.addGestureRecognizer(touchEventStream.gesture)
    }
}
