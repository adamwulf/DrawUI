//
//  Stroke.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/16/20.
//

import Foundation

public class Stroke {

    // MARK: - Public Properties
    public private(set) var touchIdentifier: String
    public var points: [StrokePoint] {
        return confirmedPoints + predictedPoints
    }
    public var isComplete: Bool {
        let phase = confirmedPoints.last?.event.phase
        return (phase == .ended || phase == .cancelled) && predictedPoints.isEmpty && expectingUpdate.isEmpty
    }

    // MARK: - Private Properties
    private var confirmedPoints: [StrokePoint]
    private var predictedPoints: [StrokePoint]

    private var expectingUpdate: [String]
    private var touchToPoint: [String: StrokePoint]
    private var touchToIndex: [String: Int]

    // MARK: - Init
    init?(touchEvents: [TouchEvent]) {
        guard touchEvents.count > 0 else { return nil }
        self.confirmedPoints = []
        self.predictedPoints = []
        self.touchToPoint = [:]
        self.touchToIndex = [:]
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
            if touchToPoint[event.pointIdentifier] != nil,
               let index = touchToIndex[event.pointIdentifier] {
                touchToPoint[event.pointIdentifier]?.add(event: event)
                if !event.expectsUpdate {
                    expectingUpdate.remove(object: event.pointIdentifier)
                }
                indexSet.insert(index)
            } else if event.isPrediction {
                let prediction = StrokePoint(event: event)
                predictedPoints.append(prediction)
                let index = confirmedPoints.count + predictedPoints.count - 1
                touchToIndex[event.pointIdentifier] = index
                indexSet.insert(index)
            } else if
                let point = consumable.first {
                if event.expectsUpdate {
                    expectingUpdate.append(event.pointIdentifier)
                }
                point.add(event: event)
                consumable.removeFirst()
                touchToPoint[event.pointIdentifier] = point
                confirmedPoints.append(point)
                let index = confirmedPoints.count - 1
                touchToIndex[event.pointIdentifier] = index
                indexSet.insert(index)
            } else {
                if event.expectsUpdate {
                    expectingUpdate.append(event.pointIdentifier)
                }
                let point = StrokePoint(event: event)
                touchToPoint[event.pointIdentifier] = point
                confirmedPoints.append(point)
                let index = confirmedPoints.count - 1
                touchToIndex[event.pointIdentifier] = index
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

extension Stroke: Hashable {
    public static func == (lhs: Stroke, rhs: Stroke) -> Bool {
        return lhs.touchIdentifier == rhs.touchIdentifier
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(touchIdentifier)
    }
}
