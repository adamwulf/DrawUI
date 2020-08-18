//
//  StrokeStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/17/20.
//

import UIKit

public class StrokeStream {

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

    public var onChange: ((_ strokes: [Stroke], _ deltas: [StrokeStream.Delta]) -> Void)?
    public private(set) var strokes: [Stroke]
    public private(set) var otpToIndex: [OrderedTouchPoints: Int]

    public init() {
        otpToIndex = [:]
        strokes = []
    }

    @discardableResult
    public func add(touchEvents: [TouchPointStream.Delta]) -> [Delta] {
        var deltas: [Delta] = []

        for delta in touchEvents {
            switch delta {
            case .addedTouchPoints(let stroke):
                let smoothStroke = Stroke(touchPoints: stroke)
                let index = strokes.count
                otpToIndex[stroke] = index
                strokes.append(smoothStroke)
                deltas.append(.addedStroke(stroke: index))
            case .updatedTouchPoints(let stroke, let indexSet):
                if let index = otpToIndex[stroke] {
                    let updates = strokes[index].update(with: stroke, indexSet: indexSet)
                    deltas.append(.updatedStroke(stroke: index, updatedIndexes: updates))
                }
            case .completedTouchPoints(let stroke):
                if let index = otpToIndex[stroke] {
                    deltas.append(.completedStroke(stroke: index))
                }
                break
            }
        }

        onChange?(strokes, deltas)
        return deltas
    }
}
