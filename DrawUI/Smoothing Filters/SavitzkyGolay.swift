//
//  SavitzkyGolay.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/18/20.
//

import Foundation

/// Smooths the points of the input strokes using the Savitzky–Golay filter, which smooths a stroke by fitting a polynomial, in a least squares sense, to a sliding window of its points.
/// https://en.wikipedia.org/wiki/Savitzky%E2%80%93Golay_filter
/// Coefficients are calculated with the algorithm from https://dekalogblog.blogspot.com/2013/09/savitzky-golay-filter-convolution.html
public class SavitzkyGolay: SmoothingFilter {
    public init () {

        for m in 2...12 {
            print("\(m)")
            for windowPos in 0 ..< m + 1 {
                let term = 0
                let order = 3
                print("  \(windowPos): \(weight(term, windowPos, m, order, 0))")
            }
        }
    }

    func smooth(strokes: [Stroke], deltas: [StrokeStream.Delta]) -> (strokes: [Stroke], deltas: [StrokeStream.Delta]) {

        // TODO: calculate coefficients
        // https://dekalogblog.blogspot.com/2013/09/savitzky-golay-filter-convolution.html

        // TOOD: smooth algorithm
        // https://www.centerspace.net/savitzky-golay-smoothing/

        return (strokes: strokes, deltas: deltas)
    }

    // MARK: - Coefficients

    /// calculates the generalised factorial (a)(a-1)...(a-b+1)
    func genFact(_ a: Int, _ b: Int) -> Double {
        var gf: Double = 1.0

        for jj in (a - b + 1) ..< (a + 1) {
            gf *= Double(jj)
        }
        return gf
    }

    /// Calculates the Gram Polynomial ( s = 0 ), or its s'th
    /// derivative evaluated at i, order k, over 2m + 1 points
    func gramPoly(_ i: Int, _ m: Int, _ k: Int, _ s: Int) -> Double {
        var gp_val: Double

        if k > 0 {
            let g1 = gramPoly(i, m, k - 1, s)
            let g2 = gramPoly(i, m, k - 1, s - 1)
            let g3 = gramPoly(i, m, k - 2, s)
            let i: Double = Double(i)
            let m: Double = Double(m)
            let k: Double = Double(k)
            let s: Double = Double(s)
            gp_val = (4.0 * k - 2.0) / (k * (2.0 * m - k + 1.0)) * (i * g1 + s * g2)
                - ((k - 1.0) * (2.0 * m + k)) / (k * (2.0 * m - k + 1.0)) * g3
        } else if k == 0 && s == 0 {
            gp_val = 1.0
        } else {
            gp_val = 0.0
        }
        return gp_val
    }

    /// calculates the weight of the i'th data point for the t'th Least-square
    /// point of the s'th derivative, over 2m + 1 points, order n
    func weight(_ i: Int, _ t: Int, _ m: Int, _ n: Int, _ s: Int) -> Double {
        var sum = 0.0

        for k in 0 ..< n + 1 {
            sum += Double(2 * k + 1) * Double(genFact(2 * m, k) / genFact(2 * m + k + 1, k + 1))
                * gramPoly(i, m, k, 0) * gramPoly(t, m, k, s)
        }

        return sum
    }
}
