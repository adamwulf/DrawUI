//
//  BezierView.swift
//  DrawUI
//
//  Created by Adam Wulf on 3/28/21.
//

import UIKit

public class BezierView: UIView, Consumer {

    public typealias Consumes = BezierStream.Produces

    override public func layoutSubviews() {
        setNeedsDisplay()
        super.layoutSubviews()
    }

    public func consume(_ input: BezierStream.Produces) {
        // noop
    }

    public func reset() {
        // noop
    }
}
