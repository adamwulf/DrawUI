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
        for event in touchEvents {
            if touchToPoint[event.pointIdentifier] != nil,
               let index = touchToIndex[event.identifier] {
                touchToPoint[event.pointIdentifier]?.add(event: event)
                if !event.expectsUpdate {
                    expectingUpdate.remove(object: event.pointIdentifier)
                }
                indexSet.insert(index)
            } else if event.isPrediction {
                let prediction = StrokePoint(event: event)
                predictedPoints.append(prediction)
                let index = confirmedPoints.count + predictedPoints.count - 1
                touchToIndex[event.identifier] = index
                indexSet.insert(index)
            } else if
                let point = predictedPoints.first {
                if event.expectsUpdate {
                    expectingUpdate.append(event.pointIdentifier)
                }
                point.add(event: event)
                predictedPoints.removeFirst()
                touchToPoint[event.pointIdentifier] = point
                confirmedPoints.append(point)
                let index = confirmedPoints.count - 1
                touchToIndex[event.identifier] = index
                indexSet.insert(index)
            } else {
                if event.expectsUpdate {
                    expectingUpdate.append(event.pointIdentifier)
                }
                let point = StrokePoint(event: event)
                touchToPoint[event.pointIdentifier] = point
                confirmedPoints.append(point)
                let index = confirmedPoints.count - 1
                touchToIndex[event.identifier] = index
                indexSet.insert(index)
            }
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
