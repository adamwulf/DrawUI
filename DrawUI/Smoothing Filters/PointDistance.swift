//
//  PointDistance.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/18/20.
//

import Foundation

/// Removes points from `strokes` that are within a minimum distance of each other
public class PointDistance: SmoothingFilter {
    public var enabled: Bool = true

    public init () {
    }

    public func smooth(input: StrokeStream.Output) -> StrokeStream.Output {
        return input
    }
}
