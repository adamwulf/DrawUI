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
        return map({ (id: $0.id, loc: $0.loc, pred: false, update: false) }).phased()
    }
}

extension Array where Element == TouchEvent.Complete {
    func phased() -> [TouchEvent.Phased] {
        var phaseEvents = self.map { (completeEvent) -> TouchEvent.Phased in
            return TouchEvent.Phased(event: completeEvent, phase: .moved, updatePhase: nil)
        }
        // find the .began and .ended events per touchIdentifier
        var soFar: [UITouchIdentifier] = []
        for index in phaseEvents.indices {
            let phased = phaseEvents[index]
            if !soFar.contains(phased.event.id),
               !phased.event.pred {
                soFar.append(phased.event.id)
                phaseEvents[index].phase = .began
            }
        }
        for index in phaseEvents.indices.reversed() {
            let phased = phaseEvents[index]
            if soFar.contains(phased.event.id),
               phased.phase == .moved,
               !phased.event.pred {
                soFar.remove(phased.event.id)
                phaseEvents[index].phase = .ended
            }
        }
        // Find all indices for every updated TouchEvent
        var estIndices: [EstimationUpdateIndex: NSMutableIndexSet] = [:]
        for index in phaseEvents.indices {
            if let estInd = phaseEvents[index].event.update {
                let indices = estIndices[estInd] ?? NSMutableIndexSet()
                indices.add(index)
                estIndices[estInd] = indices
            }
        }

        for estInd in estIndices.indices {
            let eventIndexes = estIndices[estInd].value
            for index in eventIndexes {
                phaseEvents[index].updatePhase = .moved
            }
            phaseEvents[eventIndexes.firstIndex].updatePhase = .began
            phaseEvents[eventIndexes.lastIndex].updatePhase = .ended
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
    func matches(_ simple: [TouchEvent.Complete]) -> Bool {
        return matches(simple.phased())
    }
}

extension TouchEvent {

    typealias Simple = (id: UITouchIdentifier, loc: CGPoint)
    typealias Complete = (id: UITouchIdentifier, loc: CGPoint, pred: Bool, update: EstimationUpdateIndex?)
    typealias Phased = (event: Complete, phase: UITouch.Phase, updatePhase: UITouch.Phase?)

    static func newFrom(_ simpleEvents: [Simple]) -> [TouchEvent] {
        return newFrom(simpleEvents.map({ (id: $0.id, loc: $0.loc, pred: false, update: false) }))
    }

    static func newFrom(_ completeEvents: [Complete]) -> [TouchEvent] {
        let phaseEvents = completeEvents.phased()

        return phaseEvents.map { (phaseEvent) -> TouchEvent in
            let hasUpdate = phaseEvent.updatePhase != nil
            return TouchEvent(touchIdentifier: phaseEvent.event.id,
                       type: .direct,
                       phase: phaseEvent.phase,
                       location: phaseEvent.event.loc,
                       estimationUpdateIndex: phaseEvent.event.update,
                       estimatedProperties: hasUpdate ? .location : .none,
                       estimatedPropertiesExpectingUpdates: hasUpdate && phaseEvent.updatePhase != .ended ? .location : .none,
                       isUpdate: hasUpdate && phaseEvent.updatePhase != .began,
                       isPrediction: phaseEvent.event.pred)
        }
    }
}
