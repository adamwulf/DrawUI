//
//  ClippedBezierStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 4/4/21.
//

import UIKit

public class ClippedBezierStream: ProducerConsumer {

    public struct Produces {
        public var paths: [UIBezierPath]
        public var deltas: [Delta]
        public init(paths: [UIBezierPath], deltas: [Delta]) {
            self.paths = paths
            self.deltas = deltas
        }

        static var empty: Produces {
            return Produces(paths: [], deltas: [])
        }
    }

    public typealias Consumes = PolylineStream.Produces

    public enum Delta: Equatable, CustomDebugStringConvertible {
        case addedBezierPath(index: Int)
        case updatedBezierPath(index: Int, updatedIndexes: IndexSet)
        case completedBezierPath(index: Int)
        case unhandled(event: DrawEvent)

        public var debugDescription: String {
            switch self {
            case .addedBezierPath(let index):
                return "addedBezierPath(\(index))"
            case .updatedBezierPath(let index, let indexSet):
                return "updatedBezierPath(\(index), \(indexSet)"
            case .completedBezierPath(let index):
                return "completedBezierPath(\(index))"
            case .unhandled(let event):
                return "unhandledEvent(\(event.identifier))"
            }
        }
    }

    // MARK: - Private

    var smoother: Smoother
    var consumers: [(process: (Produces) -> Void, reset: () -> Void)] = []
    private var builders: [BezierBuilder] = []
    /// Maps the index of a TouchPointCollection from our input to the index of the matching stroke in `strokes`
    private(set) var indexToIndex: [Int: Int] = [:]

    // MARK: - Init

    public init(smoother: Smoother) {
        self.smoother = smoother
    }

    // MARK: - Consumer<Polyline>

    public func reset() {
        builders = []
        indexToIndex = [:]
        consumers.forEach({ $0.reset() })
    }

    // MARK: - BezierStreamProducer

    public func addConsumer<Customer>(_ consumer: Customer) where Customer: Consumer, Customer.Consumes == Produces {
        consumers.append((process: { (produces: Produces) in
            consumer.consume(produces)
        }, reset: consumer.reset))
    }

    public func addConsumer(_ block: @escaping (Produces) -> Void) {
        consumers.append((process: block, reset: {}))
    }

    // MARK: - ProducerConsumer<Polyline>

    @discardableResult
    public func produce(with input: Consumes) -> Produces {
        var deltas: [Delta] = []

        for delta in input.deltas {
            switch delta {
            case .addedPolyline(let lineIndex):
                assert(indexToIndex[lineIndex] == nil, "Cannot add existing line")
                let line = input.lines[lineIndex]
                let builder = BezierBuilder(smoother: smoother)
                builder.update(with: line, at: IndexSet(0 ..< line.points.count))
                let builderIndex = builders.count
                indexToIndex[lineIndex] = builderIndex
                builders.append(builder)
                deltas.append(.addedBezierPath(index: builderIndex))
            case .updatedPolyline(let lineIndex, let updatedIndexes):
                let line = input.lines[lineIndex]
                guard let builderIndex = indexToIndex[lineIndex] else { assertionFailure("path at \(lineIndex) does not exist"); continue }
                let builder = builders[builderIndex]
                let updateElementIndexes = builder.update(with: line, at: updatedIndexes)
                deltas.append(.updatedBezierPath(index: builderIndex, updatedIndexes: updateElementIndexes))
            case .completedPolyline(let lineIndex):
                guard let index = indexToIndex[lineIndex] else { assertionFailure("path at \(lineIndex) does not exist"); continue }
                deltas.append(.completedBezierPath(index: index))
            case .unhandled(let event):
                deltas.append(.unhandled(event: event))
            }
        }

        let output = ClippedBezierStream.Produces(paths: builders.map({ $0.path }), deltas: deltas)
        consumers.forEach({ $0.process(output) })
        return output
    }

    private class BezierBuilder {
        private var elements: [BezierStream.Element] = []
        private let smoother: Smoother
        private(set) var path = UIBezierPath()

        init(smoother: Smoother) {
            self.smoother = smoother
        }

        @discardableResult
        func update(with line: Polyline, at lineIndexes: IndexSet) -> IndexSet {
            let updatedPathIndexes = smoother.elementIndexes(for: line, at: lineIndexes)
            let updatedPath: UIBezierPath
            if let min = updatedPathIndexes.min(),
               min - 1 < path.elementCount,
               min - 1 >= 0 {
                updatedPath = path.trimming(toElement: min - 1, andTValue: 1.0)
            } else {
                updatedPath = path.buildEmpty()
            }
            guard
                let min = updatedPathIndexes.min(),
                let max = updatedPathIndexes.max()
            else {
                return updatedPathIndexes
            }
            for elementIndex in min ... max {
                assert(elementIndex <= elements.count, "Invalid element index")
                if updatedPathIndexes.contains(elementIndex) {
                    let element = smoother.element(for: line, at: elementIndex)
                    if elementIndex == elements.count {
                        elements.append(element)
                    } else {
                        elements[elementIndex] = element
                    }
                    updatedPath.append(element)
                } else {
                    // use the existing element
                    let element = elements[elementIndex]
                    elements.append(element)
                    updatedPath.append(element)
                }
            }
            for elementIndex in max + 1 ..< elements.count {
                let element = elements[elementIndex]
                updatedPath.append(element)
            }
            path = updatedPath
            return updatedPathIndexes
        }
    }
}

public extension ClippedBezierStream.Produces {
    func draw(at rect: CGRect, in context: CGContext) {
        for path in paths {
            if rect.intersects(path.bounds.expand(by: path.lineWidth)) {
                if let color = path.color {
                    context.setStrokeColor(color.cgColor)
                    path.stroke()
                } else {
                    UIColor.white.setStroke()
                    path.stroke(with: .clear, alpha: 1.0)
                }
            }
        }
    }
}