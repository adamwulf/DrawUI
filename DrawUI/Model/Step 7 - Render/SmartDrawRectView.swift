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

    private var model: BezierStream.Produces = BezierStream.Produces(paths: [], deltas: [])

    public func consume(_ input: Consumes) {
        let previousModel = model
        model = input

        for delta in input.deltas {
            switch delta {
            case .addedBezierPath(let index):
                let path = model.paths[index]
                setNeedsDisplay(path.bounds.expand(by: path.lineWidth))
            case .updatedBezierPath(let index, _):
                // We could only setNeedsDisplay for the rect of the modified elements of the path.
                // For now, we'll set the entire path as needing display, but something to possibly revisit
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

    public func reset() {
        model = BezierStream.Produces(paths: [], deltas: [])
        setNeedsDisplay()
    }

    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        model.draw(at: rect, in: context)
    }
}
