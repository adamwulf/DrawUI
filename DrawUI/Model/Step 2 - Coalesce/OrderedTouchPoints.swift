//
//  OrderedTouchPoints.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/16/20.
//

import Foundation

public class OrderedTouchPoints {

    // MARK: - Public Properties
    public private(set) var touchIdentifier: String
    public var points: [TouchPoint] {
        return confirmedPoints + predictedPoints
    }
    public var isComplete: Bool {
        let phase = confirmedPoints.last?.event.phase
        return (phase == .ended || phase == .cancelled) && predictedPoints.isEmpty && expectingUpdate.isEmpty
    }

    // MARK: - Private Properties
    private var confirmedPoints: [TouchPoint]
    private var predictedPoints: [TouchPoint]
    private var expectingUpdate: [String]
    private var eventToPoint: [PointIdentifier: TouchPoint]
    private var eventToIndex: [PointIdentifier: Int]

    // MARK: - Init
    init?(touchEvents: [TouchEvent]) {
        guard touchEvents.count > 0 else { return nil }
        self.confirmedPoints = []
        self.predictedPoints = []
        self.eventToPoint = [:]
        self.eventToIndex = [:]
        self.expectingUpdate = []
        self.touchIdentifier = touchEvents.first!.touchIdentifier
        add(touchEvents: touchEvents)
    }

    @discardableResult
    func add(touchEvents: [TouchEvent]) -> IndexSet {
        var indexSet = IndexSet()
        var consumable = predictedPoints
        predictedPoints = []
        for event in touchEvents {
            if eventToPoint[event.pointIdentifier] != nil,
               let index = eventToIndex[event.pointIdentifier] {
                eventToPoint[event.pointIdentifier]?.add(event: event)
                if !event.expectsUpdate {
                    expectingUpdate.remove(object: event.pointIdentifier)
                }
                indexSet.insert(index)
            } else if event.isPrediction {
                let prediction = TouchPoint(event: event)
                predictedPoints.append(prediction)
                let index = confirmedPoints.count + predictedPoints.count - 1
                eventToIndex[event.pointIdentifier] = index
                indexSet.insert(index)
            } else if
                let point = consumable.first {
                if event.expectsUpdate {
                    expectingUpdate.append(event.pointIdentifier)
                }
                point.add(event: event)
                consumable.removeFirst()
                eventToPoint[event.pointIdentifier] = point
                confirmedPoints.append(point)
                let index = confirmedPoints.count - 1
                eventToIndex[event.pointIdentifier] = index
                indexSet.insert(index)
            } else {
                if event.expectsUpdate {
                    expectingUpdate.append(event.pointIdentifier)
                }
                let point = TouchPoint(event: event)
                eventToPoint[event.pointIdentifier] = point
                confirmedPoints.append(point)
                let index = confirmedPoints.count - 1
                eventToIndex[event.pointIdentifier] = index
                indexSet.insert(index)
            }
        }

        // we might have started with more prodicted touches than we were able to consume
        // in that case, mark the now-out-of-bounds indexes as modified since those points
        // were deleted
        for (index, _) in consumable.enumerated() {
            indexSet.insert(confirmedPoints.count + predictedPoints.count + index)
        }

        return indexSet
    }
}

extension OrderedTouchPoints: Hashable {
    public static func == (lhs: OrderedTouchPoints, rhs: OrderedTouchPoints) -> Bool {
        return lhs.touchIdentifier == rhs.touchIdentifier
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(touchIdentifier)
    }
}
