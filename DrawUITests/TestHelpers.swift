//
//  TouchEvent+TestHelpers.swift
//  DrawUITests
//
//  Created by Adam Wulf on 10/27/20.
//

import UIKit
import DrawUI

extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(_ object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
}

extension Array where Element == TouchEvent.Simple {
    func phased() -> [TouchEvent.Phased] {
        var phaseEvents = self.map { (simpleEvent) -> TouchEvent.Phased in
            return TouchEvent.Phased(event: simpleEvent, phase: .moved)
        }
        var soFar: [UITouchIdentifier] = []
        for index in phaseEvents.indices {
            if !soFar.contains(phaseEvents[index].event.id) {
                soFar.append(phaseEvents[index].event.id)
                phaseEvents[index].phase = .began
            }
        }
        for index in phaseEvents.indices.reversed() {
            if soFar.contains(phaseEvents[index].event.id),
               phaseEvents[index].phase == .moved {
                soFar.remove(phaseEvents[index].event.id)
                phaseEvents[index].phase = .ended
            }
        }
        return phaseEvents
    }
}

extension Array where Element == TouchEvent {
    func matches(_ phased: [TouchEvent.Phased]) -> Bool {
        guard count == phased.count else { return false }
        for index in phased.indices {
            let lhs = self[index]
            let rhs = phased[index]
            guard lhs.phase == rhs.phase && lhs.location == rhs.event.loc && lhs.touchIdentifier == rhs.event.id else { return false }
        }
        return true
    }

    func having(id: UITouchIdentifier) -> [TouchEvent] {
        return filter({ $0.touchIdentifier == id })
    }
}

extension Array where Element == TouchEvent {
    func matches(_ simple: [TouchEvent.Simple]) -> Bool {
        return matches(simple.phased())
    }
}

extension TouchEvent {

    typealias Simple = (id: UITouchIdentifier, loc: CGPoint)
    typealias Phased = (event: Simple, phase: UITouch.Phase)

    static func newFrom(_ simpleEvents: [Simple]) -> [TouchEvent] {
        let phaseEvents = simpleEvents.phased()

        return phaseEvents.map { (phaseEvent) -> TouchEvent in
            return TouchEvent(touchIdentifier: phaseEvent.event.id,
                              phase: phaseEvent.phase,
                              location: phaseEvent.event.loc,
                              estimatedProperties: .none,
                              estimatedPropertiesExpectingUpdates: .none,
                              isUpdate: false,
                              isPrediction: false)
        }
    }
}
