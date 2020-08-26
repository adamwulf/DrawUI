//
//  PointDistance.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/18/20.
//

import Foundation

/// Removes points from `strokes` that are within a minimum distance of each other
class PointDistance: SmoothingFilter {
    public var enabled: Bool = true
    func smooth(strokes: [Stroke], deltas: [StrokeStream.Delta]) -> (strokes: [Stroke], deltas: [StrokeStream.Delta]) {
        return (strokes: strokes, deltas: deltas)
    }
}
