//
//  DouglasPeucker.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/18/20.
//

import Foundation

class DouglasPeucker: SmoothingFilter {
    func smooth(strokes: [Stroke], deltas: [StrokeStream.Delta]) -> (strokes: [Stroke], deltas: [StrokeStream.Delta]) {
        return (strokes: strokes, deltas: deltas)
    }
}
