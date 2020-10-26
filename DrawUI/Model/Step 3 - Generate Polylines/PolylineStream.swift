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
        case addedStroke(stroke: Int)
        case updatedStroke(stroke: Int, updatedIndexes: IndexSet)
        case completedStroke(stroke: Int)

        public var rawString: String {
            switch self {
            case .addedStroke(let stroke):
                return "addedStroke(\(stroke))"
            case .updatedStroke(let stroke, let indexSet):
                return "updatedStroke(\(stroke), \(indexSet)"
            case .completedStroke(let stroke):
                return "completedStroke(\(stroke))"
            }
        }
    }

    public private(set) var strokes: [Polyline]
    /// Maps the index of a TouchPointCollection from our input to the index of the matching stroke in `strokes`
    public private(set) var indexToIndex: [TouchPointCollection: Int]

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
            case .addedTouchPoints(let pointCollection):
                let smoothStroke = Polyline(touchPoints: pointCollection)
                let index = strokes.count
                indexToIndex[pointCollection] = index
                strokes.append(smoothStroke)
                deltas.append(.addedStroke(stroke: index))
            case .updatedTouchPoints(let pointCollection, let indexSet):
                if let index = indexToIndex[pointCollection] {
                    let updates = strokes[index].update(with: pointCollection, indexSet: indexSet)
                    deltas.append(.updatedStroke(stroke: index, updatedIndexes: updates))
                }
            case .completedTouchPoints(let pointCollection):
                if let index = indexToIndex[pointCollection] {
                    deltas.append(.completedStroke(stroke: index))
                }
            }
        }

        return (strokes, deltas)
    }
}
