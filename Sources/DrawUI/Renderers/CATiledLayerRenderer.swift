//
//  CATiledLayerRenderer.swift
//  DrawUI
//
//  Created by Adam Wulf on 6/28/20.
//

import UIKit

public class CATiledLayerRenderer: DrawViewRenderer {

    public var drawModel: DrawModel?
    public var dynamicWidth: Bool
    var canvasView: UIView

    public init(view: UIView) {
        canvasView = view
        dynamicWidth = false
    }
}
