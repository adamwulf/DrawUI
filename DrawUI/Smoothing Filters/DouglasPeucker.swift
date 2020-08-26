//
//  DouglasPeucker.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/18/20.
//

import Foundation

/// Removes points from `strokes` according to the Ramer-Douglas-Peucker algorithm
/// https://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm
class DouglasPeucker: SmoothingFilter {
    public var enabled: Bool = true
    func smooth(strokes: [Stroke], deltas: [StrokeStream.Delta]) -> (strokes: [Stroke], deltas: [StrokeStream.Delta]) {
        return (strokes: strokes, deltas: deltas)
    }
}
