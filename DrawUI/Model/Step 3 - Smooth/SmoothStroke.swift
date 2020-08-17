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
    public var points: [SmoothStrokePoint] {
        // TODO: cache and smooth these points
        return stroke.points.map({ SmoothStrokePoint(point: $0) })
    }

    private var stroke: Stroke

    init(stroke: Stroke) {
        self.stroke = stroke
    }

    func update(with stroke: Stroke, indexSet: IndexSet) -> IndexSet {
        // TODO: smooth the stroke when it updates
        return IndexSet()
    }
}
