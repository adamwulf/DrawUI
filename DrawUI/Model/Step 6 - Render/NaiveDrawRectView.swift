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

    override public func draw(_ rect: CGRect) {
        for path in model.paths {
            if rect.intersects(path.bounds.expand(by: path.lineWidth)) {
                path.stroke()
            }
        }
    }
}
