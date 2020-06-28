//
//  ThumbnailRenderer.swift
//  DrawUI
//
//  Created by Adam Wulf on 6/28/20.
//

import Foundation

public class ThumbnailRenderer: DrawViewRenderer {

    public var drawModel: DrawModel?
    public var dynamicWidth: Bool

    public init(model: DrawModel) {
        drawModel = model
        dynamicWidth = false
    }
}
