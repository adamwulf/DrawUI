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
public class SavitzkyGolay: StrokeFilter {

    private let deriv: Int // 0 is smooth, 1 is first derivative, etc
    private let order: Int
    public var enabled: Bool = true {
        didSet {
            clearCaches()
        }
    }
    @Clamping(2...12) public var window: Int = 2 {
        didSet {
            clearCaches()
        }
    }
    @Clamping(0...1) public var strength: CGFloat = 1

    public init () {
        strength = 1
        deriv = 0
        order = 3
    }

    public func process(input: PolylineStream.Output) -> PolylineStream.Output {
        guard enabled else { return input }
        var outStrokes = input.strokes
        var outDeltas: [PolylineStream.Delta] = []

        func smooth(strokeIdx: Int) {
            for pIndex in 0 ..< outStrokes[strokeIdx].points.count {
                let minWin = min(min(window, pIndex), outStrokes[strokeIdx].points.count - 1 - pIndex)

                if minWin > 1 {
                    var outPoint = CGPoint.zero
                    for windowPos in -minWin ... minWin {
                        let wght = weight(0, windowPos, minWin, order, deriv)
                        outPoint.x += wght * input.strokes[strokeIdx].points[pIndex + windowPos].location.x
                        outPoint.y += wght * input.strokes[strokeIdx].points[pIndex + windowPos].location.y
                    }
                    let origPoint = outStrokes[strokeIdx].points[pIndex].location

                    outStrokes[strokeIdx].points[pIndex].location = origPoint * CGFloat(1 - strength) + outPoint * strength
                }
            }
        }

        // Temporary non-cached non-optimized smoothing
        // simply treat every stroke as brand new and smooth the entire set
        for strokeIdx in 0 ..< input.strokes.count {
            smooth(strokeIdx: strokeIdx)
            outDeltas.append(.addedPolyline(index: strokeIdx))
        }

        return (outStrokes, outDeltas)
    }

    // TODO: optimize the smoothing to cache stroke state and only re-smooth when required
    func optimized_smooth(strokes: [Polyline], deltas: [PolylineStream.Delta]) -> (strokes: [Polyline], deltas: [PolylineStream.Delta]) {
        var outStrokes = strokes

        // TODO: cache the output smooth strokes so that we can use the same result next time
        // and update it with the incoming delta. allow for clearing cache so that the smooth
        // strokes can be recalculated at will.
        //
        // add unit tests

        var outDeltas: [PolylineStream.Delta] = []
        for delta in deltas {
            switch delta {
            case .addedPolyline:
                outDeltas.append(delta)
            case .completedPolyline:
                outDeltas.append(delta)
            case .updatedPolyline(let strokeIndex, let indexes):
                let updatedIndexes = smoothStroke(stroke: &outStrokes[strokeIndex], at: indexes)
                outDeltas.append(.updatedPolyline(index: strokeIndex, updatedIndexes: updatedIndexes))
            }
        }

        return (strokes: outStrokes, deltas: outDeltas)
    }

    // MARK: - Private

    @discardableResult
    private func smoothStroke(stroke: inout Polyline, at indexes: IndexSet?) -> IndexSet {
        let outIndexes = { () -> IndexSet in
            if let indexes = indexes {
                var outIndexes = IndexSet()
                for pIndex in indexes {
                    for i in pIndex - window ... pIndex + window {
                        outIndexes.insert(i)
                    }
                }
                return outIndexes
            }
            return IndexSet(stroke.points.indices)
        }()

        for pIndex in outIndexes {
            let pCurr = stroke.points[pIndex]
            let m = min(min(window, pIndex), stroke.points.count - 1 - pIndex)

            if m >= 2 {
                var p = CGPoint.zero
                for windowPos in pIndex - m ... pIndex + m {
                    let coef = weight(0, windowPos, m, order, deriv)
                    p.x += coef * pCurr.location.x
                    p.y += coef * pCurr.location.y
                }
                stroke.points[pIndex].location = p
            }
        }

        return outIndexes
    }

    private func clearCaches() {
        // clear all of our caches, a setting has changed so all of our smoothed curves are now entirely out of date
        // and we'll need to resmooth the entire corpus of strokes next time.
    }

    // MARK: - Coefficients

    /// calculates the generalised factorial (a)(a-1)...(a-b+1)
    private func genFact(_ a: Int, _ b: Int) -> CGFloat {
        var gf: CGFloat = 1.0

        for jj in (a - b + 1) ..< (a + 1) {
            gf *= CGFloat(jj)
        }
        return gf
    }

    /// Calculates the Gram Polynomial ( s = 0 ), or its s'th
    /// derivative evaluated at i, order k, over 2m + 1 points
    private func gramPoly(_ index: Int, _ window: Int, _ order: Int, _ derivative: Int) -> CGFloat {
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
    private func weight(_ index: Int, _ windowLoc: Int, _ windowSize: Int, _ order: Int, _ derivative: Int) -> CGFloat {
        var sum: CGFloat = 0.0

        for k in 0 ..< order + 1 {
            sum += CGFloat(2 * k + 1) * CGFloat(genFact(2 * windowSize, k) / genFact(2 * windowSize + k + 1, k + 1))
                * gramPoly(index, windowSize, k, 0) * gramPoly(windowLoc, windowSize, k, derivative)
        }

        return sum
    }

    private func testCoeff() {
        for m in 2...12 {
            // for a window of 2*m+1 points ( from p[-m] => p[m],
            // the coefficents for p[0]...p[m] or p[0]...p[-m] are given
            // for a cubic curve
            print("\(m)")
            for windowPos in -m ... m {
                let term = 0 // coefficients to adjust p[0] when looking at p[-m] ... p[m]
                let order = 3 // cubic curve
                print("  \(windowPos): \(weight(term, windowPos, m, order, deriv))")
            }
        }

    }
}