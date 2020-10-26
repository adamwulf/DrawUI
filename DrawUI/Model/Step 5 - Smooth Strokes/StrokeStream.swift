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
        case addedStroke(strokeIndex: Int)
        case updatedStroke(strokeIndex: Int, updatedElements: IndexSet)
        case completedStroke(strokeIndex: Int)
    }

    @Clamping(0...1) public var smoothness: CGFloat = 0.7
    public private(set) var strokes: [Stroke]
    public private(set) var indexToIndex: [Int: Int]

    init() {
        strokes = []
        indexToIndex = [:]
    }

    @discardableResult
    public func process(input: PolylineStream.Output) -> Output {
        let pointCollectionDeltas = input.deltas
        var deltas: [Delta] = []

        for delta in pointCollectionDeltas {
            switch delta {
            case .addedStroke(let polylineIndex):
                let polyline = input.strokes[polylineIndex]
                assert(!polyline.points.isEmpty, "Added Stroke must have at least one point")
                let strokeIndex = strokes.count
                indexToIndex[polylineIndex] = strokeIndex
                strokes.append(Stroke(polyline: polyline))
                deltas.append(.addedStroke(strokeIndex: strokeIndex))
            case .completedStroke(let polylineIndex):
                guard let strokeIndex = indexToIndex[polylineIndex] else {
                    assertionFailure("Don't have matching Stroke for Polyline index \(polylineIndex)")
                    continue
                }
                strokes[strokeIndex].markCompleted()
                deltas.append(.completedStroke(strokeIndex: strokeIndex))
            case .updatedStroke(let polylineIndex, let updatedIndexes):
                guard let strokeIndex = indexToIndex[polylineIndex] else {
                    assertionFailure("Don't have matching Stroke for Polyline index \(polylineIndex)")
                    continue
                }
                let polyline = input.strokes[polylineIndex]
                let updatedElements = strokes[strokeIndex].update(with: polyline, indexSet: updatedIndexes)
                deltas.append(.updatedStroke(strokeIndex: strokeIndex, updatedElements: updatedElements))
            }
        }

        return (strokes, deltas)
    }
}
