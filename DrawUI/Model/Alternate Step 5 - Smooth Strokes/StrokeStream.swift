//
//  StrokeStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 10/26/20.
//

import UIKit

public class StrokeStream {

    public typealias Output = (strokes: [Stroke], deltas: [Delta])

    public enum Delta {
        case addedStroke(index: Int)
        case updatedStroke(index: Int, updatedElements: IndexSet)
        case completedStroke(index: Int)
    }

    @Clamping(0...1) public var smoothness: CGFloat = 0.7
    public private(set) var strokes: [Stroke]
    public private(set) var indexToIndex: [Int: Int]

    init() {
        strokes = []
        indexToIndex = [:]
    }

    @discardableResult
    public func process(input: PolylineStream.Produces) -> Output {
        let pointCollectionDeltas = input.deltas
        var deltas: [Delta] = []

        for delta in pointCollectionDeltas {
            switch delta {
            case .addedPolyline(let polylineIndex):
                let polyline = input.lines[polylineIndex]
                assert(!polyline.points.isEmpty, "Added Stroke must have at least one point")
                let strokeIndex = strokes.count
                indexToIndex[polylineIndex] = strokeIndex
                let stroke = Stroke(polyline: polyline, smoothness: smoothness)
                strokes.append(stroke)
                deltas.append(.addedStroke(index: strokeIndex))
            case .completedPolyline(let polylineIndex):
                guard let strokeIndex = indexToIndex[polylineIndex] else {
                    assertionFailure("Don't have matching Stroke for Polyline index \(polylineIndex)")
                    continue
                }
                strokes[strokeIndex].markCompleted()
                deltas.append(.completedStroke(index: strokeIndex))
            case .updatedPolyline(let polylineIndex, let updatedIndexes):
                guard let strokeIndex = indexToIndex[polylineIndex] else {
                    assertionFailure("Don't have matching Stroke for Polyline index \(polylineIndex)")
                    continue
                }
                let polyline = input.lines[polylineIndex]
                let updatedElements = strokes[strokeIndex].update(with: polyline, indexSet: updatedIndexes)
                deltas.append(.updatedStroke(index: strokeIndex, updatedElements: updatedElements))
            }
        }

        return (strokes, deltas)
    }
}
