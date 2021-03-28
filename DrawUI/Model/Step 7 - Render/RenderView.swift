//
//  RenderView.swift
//  DrawUI
//
//  Created by Adam Wulf on 3/28/21.
//

import UIKit

public class RenderView: UIView, Consumer {

    public typealias Consumes = BezierStream.Produces

    public func consume(_ input: BezierStream.Produces) {
        // noop
    }

    public func reset() {
        // noop
    }
}
