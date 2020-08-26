//
//  SmoothingFilter.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/18/20.
//

import Foundation

// Also, some future smoothing algorithm ideas:
// https://en.wikipedia.org/wiki/Smoothing

protocol SmoothingFilter {
    var enabled: Bool { get set }
    func smooth(strokes: [Stroke], deltas: [StrokeStream.Delta]) -> (strokes: [Stroke], deltas: [StrokeStream.Delta])
}
