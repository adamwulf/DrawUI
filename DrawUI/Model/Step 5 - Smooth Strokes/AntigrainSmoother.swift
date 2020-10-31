//
//  AntigrainSmoother.swift
//  DrawUI
//
//  Created by Adam Wulf on 10/31/20.
//

import Foundation

public class AntigrainSmoother {
    public static func smoothedIndexesFor(polyline: Polyline, indexes: IndexSet) -> IndexSet {
        var curveIndexes = IndexSet()

        for index in indexes {
            curveIndexes.formUnion(smoothedIndexesFor(polyline: polyline, index: index))
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
    public static func smoothedIndexesFor(polyline: Polyline, index: IndexSet.Element) -> IndexSet {
        assert(index < polyline.points.count)
        let maxIndex = { () -> Int in
            if polyline.points.count == 3 {
                // special case, where we use a quadratic curve instead of cubic curve to fit
                return 1
            }
            return Swift.max(0, polyline.points.count - 3)
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

extension Array where Element == Polyline.Point {
    public func indexAffectedBy(indexes: IndexSet) -> IndexSet {
        var curveIndexes = IndexSet()

        for index in indexes {
            curveIndexes.formUnion(indexesUsedAtIndex(index: index))
        }

        return curveIndexes
    }

    // Below are the examples of input indexes, and which smoothed elements that point index affects
    // 0 => 1, 0
    // 1 => 2, 1, 0
    // 2 => 3, 2, 1
    // 3 => 4, 3, 2
    // 4 => 5, 4, 3, 2
    // 5 => 6, 5, 4, 3
    // 6 => 7, 6, 5, 4
    // 7 => 8, 7, 6, 5
    public func indexesUsedAtIndex(index: IndexSet.Element) -> IndexSet {
        assert(index < count)
        let maxIndex = Swift.max(0, count - 2)
        var ret = IndexSet()

        if index > 0 {
            ret.insert(index - 1)
        }
        if index > 1 {
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
