//
//  PolylineStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/17/20.
//

import UIKit

public class PolylineStream {

    public typealias Output = (strokes: [Polyline], deltas: [Delta])

    public enum Delta {
        case addedPolyline(index: Int)
        case updatedPolyline(index: Int, updatedIndexes: IndexSet)
        case completedPolyline(index: Int)

        public var rawString: String {
            switch self {
            case .addedPolyline(let index):
                return "addedPolyline(\(index))"
            case .updatedPolyline(let index, let indexSet):
                return "updatedPolyline(\(index), \(indexSet)"
            case .completedPolyline(let index):
                return "completedPolyline(\(index))"
            }
        }
    }

    public private(set) var strokes: [Polyline]
    /// Maps the index of a TouchPointCollection from our input to the index of the matching stroke in `strokes`
    public private(set) var indexToIndex: [Int: Int]

    public init() {
        indexToIndex = [:]
        strokes = []
    }

    @discardableResult
    public func process(input: TouchPointStream.Output) -> Output {
        let pointCollectionDeltas = input.deltas
        var deltas: [Delta] = []

        for delta in pointCollectionDeltas {
            switch delta {
            case .addedTouchPoints(let pointCollectionIndex):
                let pointCollection = input.pointCollections[pointCollectionIndex]
                let smoothStroke = Polyline(touchPoints: pointCollection)
                let index = strokes.count
                indexToIndex[pointCollectionIndex] = index
                strokes.append(smoothStroke)
                deltas.append(.addedPolyline(index: index))
            case .updatedTouchPoints(let pointCollectionIndex, let indexSet):
                let pointCollection = input.pointCollections[pointCollectionIndex]
                if let index = indexToIndex[pointCollectionIndex] {
                    let updates = strokes[index].update(with: pointCollection, indexSet: indexSet)
                    deltas.append(.updatedPolyline(index: index, updatedIndexes: updates))
                }
            case .completedTouchPoints(let pointCollectionIndex):
                if let index = indexToIndex[pointCollectionIndex] {
                    deltas.append(.completedPolyline(index: index))
                }
            }
        }

        return (strokes, deltas)
    }
}
