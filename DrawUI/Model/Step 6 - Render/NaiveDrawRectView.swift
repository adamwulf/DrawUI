//
//  NaiveDrawRectView.swift
//  DrawUI
//
//  Created by Adam Wulf on 3/15/21.
//

import UIKit
import MMSwiftToolbox
import PerformanceBezier

public class NaiveDrawRectView: UIView, BezierStreamConsumer {

    private var model: BezierStream.Output = (paths: [], deltas: [])

    public func process(_ input: BezierStream.Output) {
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
