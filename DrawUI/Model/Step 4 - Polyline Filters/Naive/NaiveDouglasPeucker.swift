//
//  NaiveDouglasPeucker.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/18/20.
//

import Foundation

/// Removes points from `strokes` according to the Ramer-Douglas-Peucker algorithm
/// https://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm
public class NaiveDouglasPeucker: PolylineStreamProducer, PolylineStreamConsumer {

    // MARK: - Private

    private var consumers: [PolylineStreamConsumer] = []

    // MARK: - Public

    public var enabled: Bool = true

    // MARK: Init

    public init () {
    }

    // MARK: - PolylineStreamProducer

    public func addConsumer(_ consumer: PolylineStreamConsumer) {
        consumers.append(consumer)
    }

    public func addConsumer(_ block: @escaping (PolylineStream.Output) -> Void) {
        addConsumer(AnonymousPolylineStreamConsumer(block: block))
    }

    // MARK: - PolylineStreamConsumer

    public func process(_ input: PolylineStream.Output) {
        guard enabled else {
            consumers.forEach({ $0.process(input) })
            return
        }

        // TODO: implement Douglas-Peucker algorithm to reduce the number of points
        consumers.forEach({ $0.process(input) })
    }
}
