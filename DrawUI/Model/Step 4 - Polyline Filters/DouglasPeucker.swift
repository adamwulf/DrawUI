//
//  DouglasPeucker.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/18/20.
//

import Foundation

/// Removes points from `strokes` according to the Ramer-Douglas-Peucker algorithm
/// https://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm
public class DouglasPeucker: PolylineFilter {
    public var enabled: Bool = true

    public init () {
    }

    public func process(input: PolylineStream.Output) -> PolylineStream.Output {
        guard enabled else { return input }

        // TODO: implement Douglas-Peucker algorithm to reduce the number of points
        return input
    }
}
