//
//  PolylineStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/17/20.
//

import UIKit

public class PolylineStream: ProducerConsumer {
    public typealias Consumes = TouchPathStream.Produces
    public typealias Produces = (lines: [Polyline], deltas: [Delta])

    public enum Delta: Equatable, CustomDebugStringConvertible {
        case addedPolyline(index: Int)
        case updatedPolyline(index: Int, updatedIndexes: IndexSet)
        case completedPolyline(index: Int)

        public var debugDescription: String {
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

    // MARK: - Private

    private var consumers: [(process: (Produces) -> Void, reset: () -> Void)] = []

    // MARK: - Public

    public private(set) var lines: [Polyline]
    /// Maps the index of a TouchPointCollection from our input to the index of the matching stroke in `strokes`
    public private(set) var indexToIndex: [Int: Int]

    // MARK: - Init

    public init() {
        indexToIndex = [:]
        lines = []
    }

    // MARK: - ProducerConsumer<Polyline>

    public func reset() {
        indexToIndex = [:]
        lines = []
        consumers.forEach({ $0.reset() })
    }

    // MARK: - Producer<Polyline>

    public func addConsumer<Customer>(_ consumer: Customer) where Customer: Consumer, Customer.Consumes == Produces {
        consumers.append((process: { (produces: Produces) in
            consumer.consume(produces)
        }, reset: consumer.reset))
    }

    public func addConsumer(_ block: @escaping (Produces) -> Void) {
        consumers.append((process: block, reset: {}))
    }

    // MARK: - Consumer<TouchPath>

    public func consume(_ input: TouchPathStream.Produces) {
        produce(with: input)
    }

    @discardableResult
    public func produce(with input: Consumes) -> Produces {
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

        let output = (lines, deltas)
        consumers.forEach({ $0.process(output) })
        return output
    }
}
