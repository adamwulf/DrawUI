//
//  NaivePointDistance.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/18/20.
//

import Foundation

/// Removes points from `strokes` that are within a minimum distance of each other
public class NaivePointDistance: Producer, Consumer {
    public typealias Consumes = PolylineStream.Produces
    public typealias Produces = PolylineStream.Produces

    // MARK: - Private

    public private(set) var consumers: [(Produces) -> Void] = []

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

        // TODO: implement filtering a stroke's points by their distance
        consumers.forEach({ $0(input) })
    }
}
