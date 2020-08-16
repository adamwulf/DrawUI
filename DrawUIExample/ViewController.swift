//
//  ViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit
import DrawUI

class ViewController: UIViewController {

    let touchStreamGesture: UIGestureRecognizer
    var touchStream: EventStream
    var debugView: DebugView? {
        return view as? DebugView
    }

    required init?(coder: NSCoder) {
        let touchStream = TouchesEventStream()
        touchStreamGesture = touchStream.gesture
        self.touchStream = touchStream
        super.init(coder: coder)

        touchStream.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        debugView?.touchStream = touchStream
        debugView?.addGestureRecognizer(touchStreamGesture)
    }
}

extension ViewController: EventStreamDelegate {
    func touchStreamChanged(_ touchStream: EventStream) {
        debugView?.setNeedsDisplay()
    }
}
