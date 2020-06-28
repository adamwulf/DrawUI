//
//  MMPen.swift
//  DrawUI
//
//  Created by Adam Wulf on 6/28/20.
//

import UIKit

public class Pen {
    var color: UIColor?
    var lastWidth: CGFloat
    var shortStrokeEnding: Bool

    public init(minSize: CGFloat, maxSize: CGFloat, color: UIColor?) {
        lastWidth = minSize
        shortStrokeEnding = false
        self.color = color
    }
}
