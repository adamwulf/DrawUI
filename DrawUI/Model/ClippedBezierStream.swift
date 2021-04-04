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

    public typealias Consumes = BezierStream.Produces

    public enum Delta: Equatable, CustomDebugStringConvertible {
        case addedBezierPath(index: Int)
        case updatedBezierPath(index: Int, updatedElementIndexes: IndexSet)
        case completedBezierPath(index: Int)
        case replacedBezierPath(index: Int, withPathIndexes: IndexSet)
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
            case .unhandled(let event):
                return "unhandledEvent(\(event.identifier))"
            }
        }
    }

    // MARK: - Private

    var consumers: [(process: (Produces) -> Void, reset: () -> Void)] = []
    /// Maps the index of a TouchPointCollection from our input to the index of the matching stroke in `strokes`
    private(set) var indexToIndex: [Int: Int] = [:]

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
        var output = Produces(paths: input.paths, deltas: [])
        for delta in input.deltas {
            switch delta {
            case .addedBezierPath(let index):
                output.deltas += [.addedBezierPath(index: index)]
            case .updatedBezierPath(let index, let updatedIndexes):
                output.deltas += [.updatedBezierPath(index: index, updatedElementIndexes: updatedIndexes)]
            case .completedBezierPath(let index):
                output.deltas += [.completedBezierPath(index: index)]
            case .unhandled(let event):
                output.deltas += [.unhandled(event: event)]
            }
        }

        consumers.forEach({ $0.process(output) })
        return output
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
