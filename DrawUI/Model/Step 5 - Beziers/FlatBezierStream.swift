//
//  FlatBezierStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 3/14/21.
//

import Foundation
import UIKit

public class FlatBezierStream: BezierStream, PolylineStreamConsumer {

    // MARK: - Private

    public private(set) var paths: [UIBezierPath]
    /// Maps the index of a TouchPointCollection from our input to the index of the matching stroke in `strokes`
    public private(set) var indexToIndex: [Int: Int]

    // MARK: - Init

    override public init() {
        indexToIndex = [:]
        paths = []
        super.init()
    }

    // MARK: - PolylineStreamConsumer

    public func process(_ input: PolylineStream.Output) {
        var deltas: [Delta] = []

        for delta in input.deltas {
            switch delta {
            case .addedPolyline(let lineIndex):
                let line = input.lines[lineIndex]
                let path = UIBezierPath(polyline: line)
                let index = paths.count
                indexToIndex[lineIndex] = index
                paths.append(path)
                deltas.append(.addedBezierPath(index: index))
            case .updatedPolyline(let lineIndex, let updatedEleIndexes):
                let line = input.lines[lineIndex]
                let path = UIBezierPath(polyline: line)
                guard let index = indexToIndex[lineIndex] else { assertionFailure("path at \(lineIndex) does not exist"); continue }
                paths[index] = path
                deltas.append(.updatedBezierPath(index: index, updatedIndexes: updatedEleIndexes))
            case .completedPolyline(let lineIndex):
                guard let index = indexToIndex[lineIndex] else { assertionFailure("path at \(lineIndex) does not exist"); continue }
                deltas.append(.completedBezierPath(index: index))
            }
        }

        let output = (paths: paths, deltas: deltas)
        consumers.forEach({ $0.process(output) })
    }
}

extension UIBezierPath {
    convenience init(polyline: Polyline) {
        self.init()
        var points = polyline.points
        guard let startPoint = points.popFirst() else { return }
        move(to: startPoint.location)
        lineWidth = max(startPoint.force, 1)

        for point in points {
            addLine(to: point.location)
        }
    }
}
