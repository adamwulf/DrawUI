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
    @IBOutlet var pathView: PathView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        touchEventStream.addConsumer(touchPathStream)
        touchPathStream.addConsumer(strokeStream)
        strokeStream.addConsumer(pathStream)
        pathStream.addConsumer { [weak self] (input) in
            self?.pathView.update(with: input)
        }

        pathStream.addConsumer { (input) in
            print("pathCount: \(input.paths.count) updatedCount:\(input.deltas.count)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pathView?.addGestureRecognizer(touchEventStream.gesture)
    }
}

class PathView: UIView {
    private var model: BezierStream.Output = (paths: [], deltas: [])

    func update(with input: BezierStream.Output) {
        model = input

        for delta in input.deltas {
            switch delta {
            case .addedBezierPath(let index):
                let path = model.paths[index]
                setNeedsDisplay(path.bounds.expand(by: path.lineWidth))
            case .updatedBezierPath(let index, _):
                let path = model.paths[index]
                setNeedsDisplay(path.bounds.expand(by: path.lineWidth))
            case .completedBezierPath:
                break
            }
        }
    }
}
