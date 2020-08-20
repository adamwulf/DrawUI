//
//  SavitzkyGolay.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/18/20.
//

import UIKit

/// Smooths the points of the input strokes using the Savitzky–Golay filter, which smooths a stroke by fitting a polynomial, in a least squares sense, to a sliding window of its points.
/// https://en.wikipedia.org/wiki/Savitzky%E2%80%93Golay_filter
/// Coefficients are calculated with the algorithm from https://dekalogblog.blogspot.com/2013/09/savitzky-golay-filter-convolution.html
/// Values were confirmed against the coefficients listed at http://www.statistics4u.info/fundstat_eng/cc_savgol_coeff.html
public class SavitzkyGolay: SmoothingFilter {
    public init () {
        for m in 2...12 {
            // for a window of 2*m+1 points ( from p[-m] => p[m],
            // the coefficents for p[0]...p[m] or p[0]...p[-m] are given
            // for a cubic curve
            print("\(m)")
            for windowPos in -m ... m {
                let term = 0 // coefficients to adjust p[0] when looking at p[-m] ... p[m]
                let order = 3 // cubic curve
                print("  \(windowPos): \(weight(term, windowPos, m, order, 0))")
            }
        }
    }

    func smooth(strokes: [Stroke], deltas: [StrokeStream.Delta]) -> (strokes: [Stroke], deltas: [StrokeStream.Delta]) {

        // TODO: use coefficients to smooth all points

        return (strokes: strokes, deltas: deltas)
    }

    // MARK: - Coefficients

    /// calculates the generalised factorial (a)(a-1)...(a-b+1)
    func genFact(_ a: Int, _ b: Int) -> CGFloat {
        var gf: CGFloat = 1.0

        for jj in (a - b + 1) ..< (a + 1) {
            gf *= CGFloat(jj)
        }
        return gf
    }

    /// Calculates the Gram Polynomial ( s = 0 ), or its s'th
    /// derivative evaluated at i, order k, over 2m + 1 points
    func gramPoly(_ index: Int, _ window: Int, _ order: Int, _ derivative: Int) -> CGFloat {
        var gp_val: CGFloat

        if order > 0 {
            let g1 = gramPoly(index, window, order - 1, derivative)
            let g2 = gramPoly(index, window, order - 1, derivative - 1)
            let g3 = gramPoly(index, window, order - 2, derivative)
            let i: CGFloat = CGFloat(index)
            let m: CGFloat = CGFloat(window)
            let k: CGFloat = CGFloat(order)
            let s: CGFloat = CGFloat(derivative)
            gp_val = (4.0 * k - 2.0) / (k * (2.0 * m - k + 1.0)) * (i * g1 + s * g2)
                - ((k - 1.0) * (2.0 * m + k)) / (k * (2.0 * m - k + 1.0)) * g3
        } else if order == 0 && derivative == 0 {
            gp_val = 1.0
        } else {
            gp_val = 0.0
        }
        return gp_val
    }

    /// calculates the weight of the i'th data point for the t'th Least-square
    /// point of the s'th derivative, over 2m + 1 points, order n
    func weight(_ index: Int, _ windowLoc: Int, _ windowSize: Int, _ order: Int, _ derivative: Int) -> CGFloat {
        var sum: CGFloat = 0.0

        for k in 0 ..< order + 1 {
            sum += CGFloat(2 * k + 1) * CGFloat(genFact(2 * windowSize, k) / genFact(2 * windowSize + k + 1, k + 1))
                * gramPoly(index, windowSize, k, 0) * gramPoly(windowLoc, windowSize, k, derivative)
        }

        return sum
    }
}
