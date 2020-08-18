//
//  SmoothingFilter.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/18/20.
//

import Foundation

protocol SmoothingFilter {
    func smooth(strokes: [Stroke], deltas: [StrokeStream.Delta]) -> (strokes: [Stroke], deltas: [StrokeStream.Delta])
}
