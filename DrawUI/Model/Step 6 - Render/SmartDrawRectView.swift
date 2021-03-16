//
//  SmartDrawRectView.swift
//  DrawUI
//
//  Created by Adam Wulf on 3/15/21.
//

import UIKit
import MMSwiftToolbox

public class SmartDrawRectView: UIView, Consumer {

    public typealias Consumes = BezierStream.Produces

    private var model: BezierStream.Produces = (paths: [], deltas: [])

    public func consume(_ input: Consumes) {
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

    override public func draw(_ rect: CGRect) {
        for path in model.paths {
            if rect.intersects(path.bounds.expand(by: path.lineWidth)) {
                path.stroke()
            }
        }
    }
}
