//
//  AntigrainSmoother.swift
//  DrawUI
//
//  Created by Adam Wulf on 10/31/20.
//

import Foundation
import UIKit

public class AntigrainSmoother {

    let smoothFactor: CGFloat = 0.7

    public init() { }

    public enum Element: Equatable {
        public static func == (lhs: AntigrainSmoother.Element, rhs: AntigrainSmoother.Element) -> Bool {
            if case let .moveTo(point: lpoint) = lhs,
               case let .moveTo(point: rpoint) = rhs {
                return lpoint.touchPoint == rpoint.touchPoint
            }
            if case let .curveTo(point: lpoint, ctrl1: lctrl1, ctrl2: lctrl2) = lhs,
               case let .curveTo(point: rpoint, ctrl1: rctrl1, ctrl2: rctrl2) = rhs {
                return lpoint.touchPoint == rpoint.touchPoint && lctrl1 == rctrl1 && lctrl2 == rctrl2
            }
            return false
        }

        case moveTo(point: Polyline.Point)
        case curveTo(point: Polyline.Point, ctrl1: CGPoint, ctrl2: CGPoint)

        public var rawString: String {
            switch self {
            case .moveTo(let point):
                return "moveTo(\(point.location))"
            case .curveTo(let point, let ctrl1, let ctrl2):
                return "curveTo(\(point.location), \(ctrl1), \(ctrl2))"
            }
        }
    }

    public func elementIn(line: Polyline, at index: Int) -> AntigrainSmoother.Element {
        assert(index >= 0 && index <= line.antigrainMaxIndex)

        if index == 0 {
            if line.points.count > 1 {
                return .moveTo(point: line.points[0])
            }
            return .moveTo(point: line.points[0])
        }

        if index == 1,
           line.points.count == 3 {
            return new(p1: line.points[0], p2: line.points[1], p3: line.points[2])
        }

        return new(p0: line.points[index - 1], p1: line.points[index], p2: line.points[index + 1], p3: line.points[index + 2])
    }

    private func new(p0: Polyline.Point? = nil, p1: Polyline.Point, p2: Polyline.Point, p3: Polyline.Point) -> Element {
        let p0 = p0 ?? p1

        let c1 = CGPoint(x: (p0.x + p1.x) / 2.0, y: (p0.y + p1.y) / 2.0)
        let c2 = CGPoint(x: (p1.x + p2.x) / 2.0, y: (p1.y + p2.y) / 2.0)
        let c3 = CGPoint(x: (p2.x + p3.x) / 2.0, y: (p2.y + p3.y) / 2.0)

        let len1 = sqrt((p1.x - p0.x) * (p1.x - p0.x) + (p1.y - p0.y) * (p1.y - p0.y))
        let len2 = sqrt((p2.x - p1.x) * (p2.x - p1.x) + (p2.y - p1.y) * (p2.y - p1.y))
        let len3 = sqrt((p3.x - p2.x) * (p3.x - p2.x) + (p3.y - p2.y) * (p3.y - p2.y))

        let k1 = len1 / (len1 + len2)
        let k2 = len2 / (len2 + len3)

        let m1 = CGPoint(x: c1.x + (c2.x - c1.x) * k1, y: c1.y + (c2.y - c1.y) * k1)
        let m2 = CGPoint(x: c2.x + (c3.x - c2.x) * k2, y: c2.y + (c3.y - c2.y) * k2)

        // Resulting control points. Here smooth_value is mentioned
        // above coefficient K whose value should be in range [0...1].
        var ctrl1 = CGPoint(x: m1.x + (c2.x - m1.x) * smoothFactor + p1.x - m1.x,
                              y: m1.y + (c2.y - m1.y) * smoothFactor + p1.y - m1.y)

        var ctrl2 = CGPoint(x: m2.x + (c2.x - m2.x) * smoothFactor + p2.x - m2.x,
                            y: m2.y + (c2.y - m2.y) * smoothFactor + p2.y - m2.y)

        if ctrl1.x.isNaN || ctrl1.y.isNaN {
            ctrl1 = p1.location
        }

        if ctrl2.x.isNaN || ctrl2.y.isNaN {
            ctrl2 = p2.location
        }

        return .curveTo(point: p2, ctrl1: ctrl1, ctrl2: ctrl2)
    }
}

extension Polyline {

    fileprivate var antigrainMaxIndex: Int {
        if points.count == 3 {
            // special case, where we use a quadratic curve instead of cubic curve to fit
            return 1
        }
        return Swift.max(0, points.count - 3)
    }

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
    public func antigrainIndexesFor(index: Int) -> IndexSet {
        assert(index < points.count)
        let maxIndex = antigrainMaxIndex
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
