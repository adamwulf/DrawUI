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
    let strokeStream = PolylineStream()
    let pathStream = FlatBezierStream()
    @IBOutlet var pathView: SmartDrawRectView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        touchEventStream.addConsumer(touchPathStream)
        touchPathStream.addConsumer(strokeStream)
        strokeStream.addConsumer(pathStream)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pathStream.addConsumer(pathView)
        pathView?.addGestureRecognizer(touchEventStream.gesture)
    }
}
