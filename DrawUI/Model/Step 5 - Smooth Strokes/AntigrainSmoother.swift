//
//  AntigrainSmoother.swift
//  DrawUI
//
//  Created by Adam Wulf on 10/31/20.
//

import Foundation

extension Polyline {
    public func antigrainIndexesFor(indexes: IndexSet) -> IndexSet {
        var curveIndexes = IndexSet()

        for index in indexes {
            curveIndexes.formUnion(antigrainIndexesFor(index: index))
        }

        return curveIndexes
    }

    // Below are the examples of input indexes, and which smoothed elements that point index affects
    // 0 => 1, 0
    // 1 => 2, 1, 0
    // 2 => 3, 2, 1
    // 3 => 4, 3, 2, 1
    // 4 => 5, 4, 3, 2
    // 5 => 6, 5, 4, 3
    // 6 => 7, 6, 5, 4
    // 7 => 8, 7, 6, 5
    public func antigrainIndexesFor(index: IndexSet.Element) -> IndexSet {
        assert(index < points.count)
        let maxIndex = { () -> Int in
            if points.count == 3 {
                // special case, where we use a quadratic curve instead of cubic curve to fit
                return 1
            }
            return Swift.max(0, points.count - 3)
        }()
        var ret = IndexSet()

        if index > 0,
           index - 1 <= maxIndex {
            ret.insert(index - 1)
        }
        if index > 2,
           index - 2 <= maxIndex {
            ret.insert(index - 2)
        }
        if index <= maxIndex {
            ret.insert(index)
        }
        if index + 1 <= maxIndex {
            ret.insert(index + 1)
        }

        return ret
    }
}
