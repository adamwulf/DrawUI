//
//  NaiveDrawRectView.swift
//  DrawUI
//
//  Created by Adam Wulf on 3/15/21.
//

import UIKit
import MMSwiftToolbox
import PerformanceBezier

public class NaiveDrawRectView: UIView, Consumer {

    public typealias Consumes = BezierStream.Produces

    private var model: BezierStream.Produces = (paths: [], deltas: [])

    public func consume(_ input: Consumes) {
        model = input

        if !input.deltas.isEmpty {
            setNeedsDisplay()
        }
    }

    public func reset() {
        model = (paths: [], deltas: [])
        setNeedsDisplay()
    }

    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        for path in model.paths {
            if rect.intersects(path.bounds.expand(by: path.lineWidth)) {
                if let color = path.color {
                    context.setStrokeColor(color.cgColor)
                    path.stroke()
                } else {
                    UIColor.white.setStroke()
                    path.stroke(with: .clear, alpha: 1.0)
                }
            }
        }
    }
}
