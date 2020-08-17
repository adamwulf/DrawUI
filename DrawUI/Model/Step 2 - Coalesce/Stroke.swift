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

    // MARK: - Private Properties
    private var confirmedPoints: [StrokePoint]
    private var predictedPoints: [StrokePoint]
    private var touchToPoint: [String: StrokePoint]

    // MARK: - Init

    init?(touchEvents: [TouchEvent]) {
        guard touchEvents.count > 0 else { return nil }
        self.confirmedPoints = []
        self.predictedPoints = []
        self.touchToPoint = [:]
        self.touchIdentifier = touchEvents.first!.touchIdentifier
        add(touchEvents: touchEvents)
    }

    func add(touchEvents: [TouchEvent]) {
        for event in touchEvents {
            if touchToPoint[event.pointIdentifier] != nil {
                touchToPoint[event.pointIdentifier]?.add(event: event)
            } else if event.isPrediction {
                let prediction = StrokePoint(event: event)
                predictedPoints.append(prediction)
            } else if let point = predictedPoints.first {
                point.add(event: event)
                predictedPoints.removeFirst()
                touchToPoint[event.pointIdentifier] = point
                confirmedPoints.append(point)
            } else {
                let point = StrokePoint(event: event)
                touchToPoint[event.pointIdentifier] = point
                confirmedPoints.append(point)
            }
        }
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
