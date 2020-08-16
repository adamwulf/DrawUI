//
//  ViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit
import DrawUI

class ViewController: UIViewController {

    let touchStream: TouchStream
    var debugView: DebugView? {
        return view as? DebugView
    }

    required init?(coder: NSCoder) {
        touchStream = TouchStream()

        super.init(coder: coder)

        touchStream.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        debugView?.touchStream = touchStream
        debugView?.addGestureRecognizer(touchStream.gesture)
    }
}

extension ViewController: TouchStreamDelegate {
    func touchStreamChanged(_ touchStream: TouchStream) {
        debugView?.setNeedsDisplay()
    }
}

