//
//  NaiveDouglasPeucker.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/18/20.
//

import Foundation

/// Removes points from `strokes` according to the Ramer-Douglas-Peucker algorithm
/// https://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm
public class NaiveDouglasPeucker: Producer, Consumer {
    public typealias Consumes = PolylineStream.Produces
    public typealias Produces = PolylineStream.Produces

    // MARK: - Private

    private var consumers: [(Produces) -> Void] = []

    // MARK: - Public

    public var enabled: Bool = true

    // MARK: Init

    public init () {
    }

    // MARK: - PolylineStreamProducer

    public func addConsumer<Customer>(_ consumer: Customer) where Customer: Consumer, Customer.Consumes == Produces {
        consumers.append({ (produces: Produces) in
            consumer.process(produces)
        })
    }

    public func addConsumer(_ block: @escaping (Produces) -> Void) {
        consumers.append(block)
    }

    // MARK: - PolylineStreamConsumer

    public func process(_ input: Consumes) {
        guard enabled else {
            consumers.forEach({ $0(input) })
            return
        }

        // TODO: implement Douglas-Peucker algorithm to reduce the number of points
        consumers.forEach({ $0(input) })
    }
}
