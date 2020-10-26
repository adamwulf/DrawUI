//
//  Stroke.swift
//  DrawUI
//
//  Created by Adam Wulf on 10/26/20.
//

import UIKit

public struct Stroke {

    public enum Element {
        case moveTo(point: StrokePoint)
        case curveTo(point: StrokePoint, ctrl1: CGPoint, ctrl2: CGPoint)
    }

    public let smoothness: CGFloat
    public private(set) var elements: [Element]
    public private(set) var isCompleted: Bool
    private let polyline: Polyline

    init(polyline: Polyline, smoothness: CGFloat) {
        self.smoothness = smoothness
        self.polyline = polyline
        self.isCompleted = polyline.isComplete
        self.elements = []

        // TODO: Initialize the elements of this stroke with the updated points of the input polyline
    }

    mutating func markCompleted() {
        assert(!isCompleted, "Cannot complete an already complete Stroke")
        isCompleted = true
    }

    /// - parameter polyline: The updated polyline that much match the same touchIdentifier of the original polyline used to create this Stroke
    /// - parameter indexSet: The indexes of the points in the polyline that have been added, changed, or removed
    /// - returns: The index set of the Elements that have been added, updated, or removed
    mutating func update(with polyline: Polyline, indexSet: IndexSet) -> IndexSet {
        assert(self.polyline.touchIdentifier == polyline.touchIdentifier, "Polyline must match touchIdentifier used to create Stroke")
        guard self.polyline.touchIdentifier == polyline.touchIdentifier else { return IndexSet() }

        // TODO: Update the elements of this stroke with the updated points of the input polyline

        return indexSet
    }
}

extension Stroke.Element {
    func new(p0: StrokePoint? = nil, p1: StrokePoint, p2: StrokePoint, p3: StrokePoint, smoothFactor: CGFloat) -> Stroke.Element {
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
