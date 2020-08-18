//
//  SavitzkyGolay.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/18/20.
//

import Foundation

/// Smooths the points of the input strokes using the Savitzky–Golay filter, which smooths a stroke by fitting a polynomial, in a least squares sense, to a sliding window of its points.
/// https://en.wikipedia.org/wiki/Savitzky%E2%80%93Golay_filter
class SavitzkyGolay: SmoothingFilter {
    func smooth(strokes: [Stroke], deltas: [StrokeStream.Delta]) -> (strokes: [Stroke], deltas: [StrokeStream.Delta]) {

        // TODO: calculate coefficients
        // https://dekalogblog.blogspot.com/2013/09/savitzky-golay-filter-convolution.html

        // TOOD: smooth algorithm
        // https://www.centerspace.net/savitzky-golay-smoothing/

        return (strokes: strokes, deltas: deltas)
    }
}
