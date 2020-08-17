//
//  ViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit
import DrawUI

class ViewController: UIViewController {

    let strokes: StrokeStream
    var debugView: DebugView? {
        return view as? DebugView
    }

    required init?(coder: NSCoder) {
        self.strokes = StrokeStream()
        super.init(coder: coder)

        strokes.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        debugView?.strokes = strokes
        debugView?.addGestureRecognizer(strokes.gesture)
    }
}

extension ViewController: StrokeStreamDelegate {
    func strokesChanged(_ strokes: StrokeStream, deltas: [StrokeStream.Delta]) {
        let updates = deltas.map({ $0.rawString })

        print("updates: \(updates)")

        debugView?.add(deltas: deltas)
        debugView?.setNeedsDisplay()
    }
}
