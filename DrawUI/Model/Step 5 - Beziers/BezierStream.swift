//
//  BezierStream.swift
//  DrawUI
//
//  Created by Adam Wulf on 3/14/21.
//

import Foundation
import UIKit

public protocol BezierStreamConsumer {
    func process(_ input: BezierStream.Output)
}

struct AnonymousBezierStreamConsumer: BezierStreamConsumer {
    var block: (BezierStream.Output) -> Void
    func process(_ input: BezierStream.Output) {
        block(input)
    }
}

public protocol BezierStreamProducer {
    func addConsumer(_ consumer: BezierStreamConsumer)

    func addConsumer(_ block: @escaping (BezierStream.Output) -> Void)
}

public class BezierStream: BezierStreamProducer {

    public typealias Output = (paths: [UIBezierPath], deltas: [Delta])

    public enum Delta: Equatable {
        case addedBezierPath(index: Int)
        case updatedBezierPath(index: Int, updatedIndexes: IndexSet)
        case completedBezierPath(index: Int)

        public var rawString: String {
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

    var consumers: [BezierStreamConsumer] = []

    // MARK: - BezierStreamProducer

    public func addConsumer(_ consumer: BezierStreamConsumer) {
        consumers.append(consumer)
    }

    public func addConsumer(_ block: @escaping (Output) -> Void) {
        addConsumer(AnonymousBezierStreamConsumer(block: block))
    }
}
