//
//  ProducerConsumer.swift
//  DrawUI
//
//  Created by Adam Wulf on 3/15/21.
//

import Foundation

public protocol Consumer {
    associatedtype Consumes
    func process(_ input: [Consumes])
}

public protocol Producer {
    associatedtype Produces

    func addConsumer<Customer>(_ consumer: Customer) where Customer: Consumer, Customer.Consumes == Produces
}

class ExampleStream: Producer {
    // How do I keep Customer generic here?
    typealias Produces = TouchEvent

    struct AnyConsumer {
        let process: ([Produces]) -> Void
    }

    var consumerClosures: [([Produces]) -> Void] = []
    var wrappedCustomers: [AnyConsumer] = []

    func addConsumer<Customer>(_ consumer: Customer) where Customer: Consumer, Customer.Consumes == Produces {
        wrappedCustomers.append(AnyConsumer(process: consumer.process))
        consumerClosures.append({ (produces: [Produces]) in
            consumer.process(produces)
        })
    }
}

struct ExampleAnonymousConsumer: Consumer {
    typealias Consumes = TouchEvent

    var block: ([TouchEvent]) -> Void
    func process(_ input: [TouchEvent]) {
        block(input)
    }
}
