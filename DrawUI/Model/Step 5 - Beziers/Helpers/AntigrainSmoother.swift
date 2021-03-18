//
//  AntigrainSmoother.swift
//  DrawUI
//
//  Created by Adam Wulf on 10/31/20.
//

import Foundation
import UIKit

extension Polyline {

    public enum Element: Equatable, CustomDebugStringConvertible {
        case moveTo(point: Polyline.Point)
        case curveTo(point: Polyline.Point, ctrl1: CGPoint, ctrl2: CGPoint)

        // MARK: CustomDebugStringConvertible

        public var debugDescription: String {
            switch self {
            case .moveTo(let point):
                return "moveTo(\(point.location))"
            case .curveTo(let point, let ctrl1, let ctrl2):
                return "curveTo(\(point.location), \(ctrl1), \(ctrl2))"
            }
        }

        // MARK: Equatable

        public static func == (lhs: Polyline.Element, rhs: Polyline.Element) -> Bool {
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
    }

    public func antigrainElement(smoothFactor: CGFloat = 0.7, at antigrainIndex: Int) -> Polyline.Element {
        assert(antigrainIndex >= 0 && antigrainIndex <= antigrainMaxIndex)

        if antigrainIndex == 0 {
            return .moveTo(point: points[0])
        }

        if antigrainIndex == 1 {
            return Self.newCurve(smoothFactor: smoothFactor,
                                 p1: points[0],
                                 p2: points[1],
                                 p3: points[2])
        }

        if isComplete && antigrainIndex == antigrainMaxIndex {
            return Self.newCurve(smoothFactor: smoothFactor,
                                 p0: points[antigrainIndex - 2],
                                 p1: points[antigrainIndex - 1],
                                 p2: points[antigrainIndex],
                                 p3: points[antigrainIndex])
        }

        return Self.newCurve(smoothFactor: smoothFactor,
                             p0: points[antigrainIndex - 2],
                             p1: points[antigrainIndex - 1],
                             p2: points[antigrainIndex],
                             p3: points[antigrainIndex + 1])
    }

    public var antigrainMaxIndex: Int {
        let lastIndex = points.count - 1
        return Swift.max(0, lastIndex - 1) + (points.count > 2 && isComplete ? 1 : 0)
    }

    public func antigrainIndexesFor(indexes: IndexSet) -> IndexSet {
        var curveIndexes = IndexSet()

        for index in indexes {
            curveIndexes.formUnion(antigrainIndexesFor(index: index))
        }

        return curveIndexes
    }

    // Below are the examples of input indexes, and which smoothed elements that point index affects
    // 0 => 2, 1, 0
    // 1 => 3, 2, 1, 0
    // 2 => 4, 3, 2, 1
    // 3 => 5, 4, 3, 2
    // 4 => 6, 5, 4, 3
    // 5 => 7, 6, 5, 4
    // 6 => 8, 7, 6, 5
    // 7 => 9, 8, 7, 6
    public func antigrainIndexesFor(index: Int) -> IndexSet {
        assert(index >= 0 && index < points.count)
        let maxIndex = antigrainMaxIndex
        var ret = IndexSet()

        if index > 1,
           index - 1 <= maxIndex {
            ret.insert(index - 1)
        }
        if index <= maxIndex {
            ret.insert(index)
        }
        if index + 1 <= maxIndex {
            ret.insert(index + 1)
        }
        if index + 2 <= maxIndex {
            ret.insert(index + 2)
        }

        return ret
    }

    // MARK: - Helper

    private static func newCurve(smoothFactor: CGFloat,
                                 p0: Polyline.Point? = nil,
                                 p1: Polyline.Point,
                                 p2: Polyline.Point,
                                 p3: Polyline.Point) -> Element {
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
