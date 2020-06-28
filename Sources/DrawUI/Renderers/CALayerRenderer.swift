//
//  CALayerRenderer.swift
//  DrawUI
//
//  Created by Adam Wulf on 6/28/20.
//

import UIKit

public class CALayerRenderer: DrawViewRenderer, CanCacheEraser {

    public var drawModel: DrawModel?
    public var dynamicWidth: Bool
    var canvasView: UIView

    public var useCachedEraserLayerType: Bool

    public init(view: UIView) {
        canvasView = view
        dynamicWidth = false
        useCachedEraserLayerType = false
    }
}
