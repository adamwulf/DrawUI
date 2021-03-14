//
//  NaivePointDistance.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/18/20.
//

import Foundation

/// Removes points from `strokes` that are within a minimum distance of each other
public class NaivePointDistance: PolylineStreamProducer, PolylineStreamConsumer {

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

        // TODO: implement filtering a stroke's points by their distance
        consumers.forEach({ $0.process(input) })
    }
}
