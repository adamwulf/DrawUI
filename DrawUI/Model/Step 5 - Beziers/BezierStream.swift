//
//  BezierStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 3/14/21.
//

import Foundation
import UIKit

public class BezierStream: ProducerConsumer {

    public typealias Produces = (paths: [UIBezierPath], deltas: [Delta])
    public typealias Consumes = PolylineStream.Produces

    public enum Delta: Equatable, CustomDebugStringConvertible {
        case addedBezierPath(index: Int)
        case updatedBezierPath(index: Int, updatedIndexes: IndexSet)
        case completedBezierPath(index: Int)

        public var debugDescription: String {
            switch self {
            case .addedBezierPath(let index):
                return "addedBezierPath(\(index))"
            case .updatedBezierPath(let index, let indexSet):
                return "updatedBezierPath(\(index), \(indexSet)"
            case .completedBezierPath(let index):
                return "completedBezierPath(\(index))"
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
            }
        }

        let output = (paths: builders.map({ $0.path }), deltas: deltas)
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

public extension BezierStream {
    enum Element: Equatable, CustomDebugStringConvertible {
        case moveTo(point: Polyline.Point)
        case lineTo(point: Polyline.Point)
        case curveTo(point: Polyline.Point, ctrl1: CGPoint, ctrl2: CGPoint)

        // MARK: CustomDebugStringConvertible

        public var debugDescription: String {
            switch self {
            case .moveTo(let point):
                return "moveTo(\(point.location))"
            case .lineTo(let point):
                return "lineTo(\(point.location))"
            case .curveTo(let point, let ctrl1, let ctrl2):
                return "curveTo(\(point.location), \(ctrl1), \(ctrl2))"
            }
        }

        // MARK: Equatable

        public static func == (lhs: BezierStream.Element, rhs: BezierStream.Element) -> Bool {
            if case let .moveTo(point: lpoint) = lhs,
               case let .moveTo(point: rpoint) = rhs {
                return lpoint.touchPoint == rpoint.touchPoint
            }
            if case let .lineTo(point: lpoint) = lhs,
               case let .lineTo(point: rpoint) = rhs {
                return lpoint.touchPoint == rpoint.touchPoint
            }
            if case let .curveTo(point: lpoint, ctrl1: lctrl1, ctrl2: lctrl2) = lhs,
               case let .curveTo(point: rpoint, ctrl1: rctrl1, ctrl2: rctrl2) = rhs {
                return lpoint.touchPoint == rpoint.touchPoint && lctrl1 == rctrl1 && lctrl2 == rctrl2
            }
            return false
        }
    }
}

public extension UIBezierPath {
    func append(_ element: BezierStream.Element) {
        switch element {
        case .moveTo(let point):
            move(to: point.location)
        case .lineTo(let point):
            assert(elementCount > 0, "must contain a moveTo")
            addLine(to: point.location)
        case .curveTo(let point, let ctrl1, let ctrl2):
            assert(elementCount > 0, "must contain a moveTo")
            addCurve(to: point.location, controlPoint1: ctrl1, controlPoint2: ctrl2)
        }
    }
}
