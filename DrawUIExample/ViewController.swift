//
//  ViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit
import DrawUI

class ViewController: UIViewController {

    let strokes: TouchPointStream
    var debugView: DebugView? {
        return view as? DebugView
    }

    required init?(coder: NSCoder) {
        self.strokes = TouchPointStream()
        super.init(coder: coder)

        strokes.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        debugView?.addGestureRecognizer(strokes.gesture)
    }
}

extension ViewController: TouchPointStreamDelegate {
    func strokesChanged(_ strokes: [OrderedTouchPoints], deltas: [TouchPointStream.Delta]) {
        let updates = deltas.map({ $0.rawString })

        print("updates: \(updates)")

        debugView?.strokes = strokes
        debugView?.add(deltas: deltas)
        debugView?.setNeedsDisplay()
    }
}
