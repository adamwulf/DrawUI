//
//  DebugRenderer.swift
//  DrawUI
//
//  Created by Adam Wulf on 6/28/20.
//

import UIKit

public class DebugRenderer: UIView, DrawViewRenderer {

    public var drawModel: DrawModel?
    public var dynamicWidth: Bool

    public init(view: UIView) {
        dynamicWidth = false
        super.init(frame: view.bounds)
        view.addSubview(self)
    }

    required init?(coder: NSCoder) {
        dynamicWidth = coder.decodeBool(forKey: "dynamicWidth")
        super.init(coder: coder)
    }
}
