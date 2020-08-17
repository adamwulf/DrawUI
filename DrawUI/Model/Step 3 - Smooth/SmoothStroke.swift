//
//  SmoothStroke.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/17/20.
//

import Foundation

public class SmoothStroke {
    // MARK: - Public Properties
    public var touchIdentifier: String {
        return stroke.touchIdentifier
    }
    public var points: [SmoothStrokePoint]

    private var stroke: Stroke

    init(stroke: Stroke) {
        self.stroke = stroke
        self.points = stroke.points.map({ SmoothStrokePoint(point: $0) })
    }

    func update(with stroke: Stroke, indexSet: IndexSet) -> IndexSet {
        for index in indexSet {
            if index < stroke.points.count {
                if index < points.count {
                    points[index].location = stroke.points[index].event.location
                } else if index == points.count {
                    points.append(SmoothStrokePoint(point: stroke.points[index]))
                } else {
                    assertionFailure("Attempting to modify a point that doesn't yet exist. maybe an update is out of order?")
                }
            } else {
                points.remove(at: index)
            }
        }
        return indexSet
    }
}
