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
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pathView?.addGestureRecognizer(touchEventStream.gesture)
    }
}

class PathView: UIView {
    private var model: BezierStream.Output = (paths: [], deltas: [])

    func update(with input: BezierStream.Output) {
        let previousModel = model
        model = input

        for delta in input.deltas {
            switch delta {
            case .addedBezierPath(let index):
                let path = model.paths[index]
                setNeedsDisplay(path.bounds.expand(by: path.lineWidth))
            case .updatedBezierPath(let index, _):
                let path = model.paths[index]
                setNeedsDisplay(path.bounds.expand(by: path.lineWidth))
                if index < previousModel.paths.count {
                    let previous = previousModel.paths[index]
                    setNeedsDisplay(previous.bounds.expand(by: previous.lineWidth))
                }
            case .completedBezierPath:
                break
            }
        }
    }

    override func draw(_ rect: CGRect) {
        for path in model.paths {
            if rect.intersects(path.bounds.expand(by: path.lineWidth)) {
                path.stroke()
            }
        }
    }
}
