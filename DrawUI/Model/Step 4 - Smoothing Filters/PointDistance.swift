//
//  PointDistance.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/18/20.
//

import Foundation

/// Removes points from `strokes` that are within a minimum distance of each other
public class PointDistance: StrokeFilter {
    public var enabled: Bool = true

    public init () {
    }

    public func process(input: PolylineStream.Output) -> PolylineStream.Output {
        guard enabled else { return input }

        // TODO: implement filtering a stroke's points by their distance
        return input
    }
}
