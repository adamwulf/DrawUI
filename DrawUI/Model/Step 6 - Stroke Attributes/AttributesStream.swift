//
//  AttributesStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 3/19/21.
//

import Foundation
import UIKit

public class AttributesStream: ProducerConsumer {

    public typealias Produces = BezierStream.Produces
    public typealias Consumes = BezierStream.Produces

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
        for delta in input.deltas {
            switch delta {
            case .addedBezierPath(let index):
                let path = input.paths[index]
                path.color = .blue
                path.lineWidth = 2.5
            default:
                break
            }
        }

        consumers.forEach({ $0.process(input) })
        return input
    }
}

public extension UIBezierPath {
    var color: UIColor? {
        get {
            let info = userInfo()
            guard let ret = info.object(forKey: "color") else { return nil }
            return ret as? UIColor
        }
        set {
            if let color = newValue {
                userInfo().setObject(color, forKey: "color" as NSString)
            } else {
                userInfo().removeObject(forKey: "color")
            }
        }
    }
}
