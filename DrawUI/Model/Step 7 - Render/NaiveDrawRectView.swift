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

    private var model: BezierStream.Produces = BezierStream.Produces(paths: [], deltas: [], events: [])

    public func consume(_ input: Consumes) {
        model = input

        if !input.deltas.isEmpty {
            setNeedsDisplay()
        }
    }

    public func reset() {
        model = BezierStream.Produces(paths: [], deltas: [], events: [])
        setNeedsDisplay()
    }

    override public func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        model.draw(at: rect, in: context)
    }
}
