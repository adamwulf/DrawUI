//
//  ProducerConsumer.swift
//  DrawUI
//
//  Created by Adam Wulf on 3/15/21.
//

import Foundation

public protocol Consumer {
    associatedtype Consumes
    func consume(_ input: Consumes)
}

public protocol Producer {
    associatedtype Produces

    func addConsumer<Customer>(_ consumer: Customer) where Customer: Consumer, Customer.Consumes == Produces
}

public protocol ProducerConsumer: Producer, Consumer {
    @discardableResult
    func produce(with input: Consumes) -> Produces
}

class ExampleStream: Producer {
    // How do I keep Customer generic here?
    typealias Produces = [TouchEvent]

    var consumers: [(Produces) -> Void] = []

    // Alternate idea to wrap them in an object instead of a loose closure
    struct AnyConsumer {
        let process: (Produces) -> Void
    }
    var wrappedCustomers: [AnyConsumer] = []

    func addConsumer<Customer>(_ consumer: Customer) where Customer: Consumer, Customer.Consumes == Produces {
        wrappedCustomers.append(AnyConsumer(process: consumer.consume))
        consumers.append({ (produces: Produces) in
            consumer.consume(produces)
        })
    }
}

struct ExampleAnonymousConsumer: Consumer {
    typealias Consumes = [TouchEvent]

    var block: ([TouchEvent]) -> Void
    func consume(_ input: [TouchEvent]) {
        block(input)
    }
}
