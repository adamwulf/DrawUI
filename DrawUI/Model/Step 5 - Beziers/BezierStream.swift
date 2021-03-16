//
//  BezierStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 3/14/21.
//

import Foundation
import UIKit

public class BezierStream: Producer {

    public typealias Produces = (paths: [UIBezierPath], deltas: [Delta])

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

    var consumers: [(Produces) -> Void] = []

    // MARK: - BezierStreamProducer

    public func addConsumer<Customer>(_ consumer: Customer) where Customer: Consumer, Customer.Consumes == Produces {
        consumers.append({ (produces: Produces) in
            consumer.consume(produces)
        })
    }

    public func addConsumer(_ block: @escaping (Produces) -> Void) {
        consumers.append(block)
    }
}
