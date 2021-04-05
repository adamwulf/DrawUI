//
//  ClippedBezierStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 4/4/21.
//

import UIKit

public class ClippedBezierStream: ProducerConsumer {

    public typealias OrderedIndexSet = OrderedSet<Int>

    public struct Produces {
        public let valid: OrderedIndexSet
        public var paths: [UIBezierPath]
        public var deltas: [Delta]
        public init(paths: [UIBezierPath], valid: OrderedIndexSet, deltas: [Delta]) {
            self.valid = valid
            self.paths = paths
            self.deltas = deltas
        }

        static var empty: Produces {
            return Produces(paths: [], valid: OrderedIndexSet(), deltas: [])
        }
    }

    public typealias Consumes = BezierStream.Produces

    public enum Delta: Equatable, CustomDebugStringConvertible {
        case addedBezierPath(index: Int)
        case updatedBezierPath(index: Int, updatedElementIndexes: IndexSet)
        case completedBezierPath(index: Int)
        case replacedBezierPath(index: Int, withPathIndexes: IndexSet)
        case invalidatedBezierPath(index: Int)
        case unhandled(event: DrawEvent)

        public var debugDescription: String {
            switch self {
            case .addedBezierPath(let index):
                return "addedBezierPath(\(index))"
            case .updatedBezierPath(let index, let indexSet):
                return "updatedBezierPath(\(index), \(indexSet)"
            case .completedBezierPath(let index):
                return "completedBezierPath(\(index))"
            case .replacedBezierPath(let index, let indexSet):
                return "replacedBezierPath(\(index), \(indexSet)"
            case .invalidatedBezierPath(let index):
                return "invalidatedBezierPath(\(index))"
            case .unhandled(let event):
                return "unhandledEvent(\(event.identifier))"
            }
        }
    }

    // MARK: - Private

    var consumers: [(process: (Produces) -> Void, reset: () -> Void)] = []
    /// Maps the index of a TouchPointCollection from our input to the index of the matching stroke in `strokes`
    private(set) var paths: [UIBezierPath] = []
    private(set) var indexToIndex: [Int: Int] = [:]
    private(set) var valid: OrderedIndexSet = OrderedIndexSet()

    // MARK: - Init

    public init() {
        // noop
    }

    // MARK: - Consumer<Polyline>

    public func reset() {
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
            case .addedBezierPath(let index):
                let myIndex = paths.count
                paths.append(input.paths[index])
                indexToIndex[index] = myIndex
                valid.append(myIndex)
                deltas += [.addedBezierPath(index: myIndex)]
            case .updatedBezierPath(let index, let updatedIndexes):
                guard let myIndex = indexToIndex[index] else { assertionFailure("path at \(index) does not exist"); continue }
                paths[myIndex] = input.paths[index]
                deltas += [.updatedBezierPath(index: myIndex, updatedElementIndexes: updatedIndexes)]
            case .completedBezierPath(let index):
                guard let myIndex = indexToIndex[index] else { assertionFailure("path at \(index) does not exist"); continue }
                let path = paths[myIndex]

                if path.color != nil {
                    deltas += [.completedBezierPath(index: myIndex)]
                } else {
                    // For eraser paths, clip all of the completed ink paths and remove the original
                    // eraser path.
                    valid.remove(myIndex)
                    deltas += [.invalidatedBezierPath(index: myIndex)]
                }
            case .unhandled(let event):
                deltas += [.unhandled(event: event)]
            }
        }

        let output = Produces(paths: paths, valid: valid, deltas: deltas)
        consumers.forEach({ $0.process(output) })
        return output
    }
}

public extension ClippedBezierStream.Produces {
    func draw(at rect: CGRect, in context: CGContext) {
        for index in valid {
            let path = paths[index]
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
