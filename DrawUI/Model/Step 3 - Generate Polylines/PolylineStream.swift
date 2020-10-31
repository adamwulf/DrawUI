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

    public private(set) var lines: [Polyline]
    /// Maps the index of a TouchPointCollection from our input to the index of the matching stroke in `strokes`
    public private(set) var indexToIndex: [Int: Int]

    public init() {
        indexToIndex = [:]
        lines = []
    }

    @discardableResult
    public func process(input: TouchPathStream.Output) -> Output {
        let pointCollectionDeltas = input.deltas
        var deltas: [Delta] = []

        for delta in pointCollectionDeltas {
            switch delta {
            case .addedTouchPath(let pathIndex):
                let line = input.paths[pathIndex]
                let smoothStroke = Polyline(touchPoints: line)
                let index = lines.count
                indexToIndex[pathIndex] = index
                lines.append(smoothStroke)
                deltas.append(.addedPolyline(index: index))
            case .updatedTouchPath(let pathIndex, let indexSet):
                let line = input.paths[pathIndex]
                if let index = indexToIndex[pathIndex] {
                    let updates = lines[index].update(with: line, indexSet: indexSet)
                    deltas.append(.updatedPolyline(index: index, updatedIndexes: updates))
                }
            case .completedTouchPath(let pointCollectionIndex):
                if let index = indexToIndex[pointCollectionIndex] {
                    deltas.append(.completedPolyline(index: index))
                }
            }
        }

        return (lines, deltas)
    }
}
