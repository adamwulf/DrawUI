//
//  ViewController.swift
//  DrawUIExample
//
//  Created by Adam Wulf on 8/16/20.
//

import UIKit
import DrawUI

class ViewController: UIViewController {

    let strokes: Strokes
    var debugView: DebugView? {
        return view as? DebugView
    }

    required init?(coder: NSCoder) {
        self.strokes = Strokes()
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

extension ViewController: StrokesDelegate {
    func strokesChanged(_ strokes: Strokes, deltas: [Strokes.Delta]) {
        let updates = deltas.map({ $0.rawString })

        print("updates: \(updates)")

        debugView?.setNeedsDisplay()
    }
}
