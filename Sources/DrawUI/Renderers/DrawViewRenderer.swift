//
//  MMDrawViewRenderer.swift
//  DrawUI
//
//  Created by Adam Wulf on 6/28/20.
//

import UIKit

public protocol DrawViewRenderer {
    var drawModel: DrawModel? { get set }
    var dynamicWidth: Bool { get set }

    func update(with drawModel: DrawModel?, bounds: CGRect)
    func drawModelDidUpdate(bounds: CGRect)
    func invalidate()
}

extension DrawViewRenderer {

    public func invalidate() {
        // noop
    }

    public func update(with drawModel: DrawModel?, bounds: CGRect) {
        // noop
    }

    public func drawModelDidUpdate(bounds: CGRect) {
        // noop
    }
}
