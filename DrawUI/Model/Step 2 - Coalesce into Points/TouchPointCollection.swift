//
//  TouchPointCollection.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/16/20.
//

import Foundation

/// Input: a stream of touch events that match our `touchIdentifier`
/// Output: coalesce all of the touch events into defined points along the stroke
///
/// The touch events may come in any order, and many events may represent the same
/// touch location, ie, a predicted touch has been updated to a final location, even though
/// other events have been added since then.
///
/// This will take a strea of events: [a1, a2, b1, a3, b2, c1] and will coalesce events for
/// the same point, so that it can output a series of points [A, B, C]
///
/// The output points also know if they are predicted, expecting updates, or is finished
public class TouchPointCollection {

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
        guard !touchEvents.isEmpty else { return nil }
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
        assert(!isComplete, "Cannot add events to a complete pointCollection")
        var indexSet = IndexSet()
        var consumable = predictedPoints
        predictedPoints = []

        for event in touchEvents {
            if
                eventToPoint[event.pointIdentifier] != nil,
                let index = eventToIndex[event.pointIdentifier] {
                // This is an update to an existing point. Add the event to the point that we already have.
                // If this is the last event that the point expects, then remove it from `expectsUpdate`
                eventToPoint[event.pointIdentifier]?.add(event: event)
                if !event.expectsUpdate {
                    expectingUpdate.remove(object: event.pointIdentifier)
                }
                indexSet.insert(index)
            } else if event.isPrediction {
                // The event is a prediction. Attempt to consume a previous prediction and reuse a Point object,
                // otherwise create a new Point and add to the predictions array
                if let prediction = consumable.first {
                    // This event is a prediction, and we can reuse one of the points from the previous predictions
                    // consume a prediction and reuse it
                    prediction.add(event: event)
                    consumable.removeFirst()
                    predictedPoints.append(prediction)
                    let index = confirmedPoints.count + predictedPoints.count - 1
                    eventToIndex[event.pointIdentifier] = index
                    indexSet.insert(index)
                } else {
                    // The event is a prediction, and we're out of consumable previous predicted points, so create a new point
                    let prediction = TouchPoint(event: event)
                    predictedPoints.append(prediction)
                    let index = confirmedPoints.count + predictedPoints.count - 1
                    eventToIndex[event.pointIdentifier] = index
                    indexSet.insert(index)
                }
            } else {
                // The event is a normal confirmed user event. Attempt to re-use a consumable point, or create a new Point
                if let point = consumable.first {
                    // The event is a new confirmed points, consume a previous prediction if possible and update it to the now
                    // confirmed point.
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
                    // We are out of consumable points, so create a new point for this event
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
        }

        // we might have started with more prodicted touches than we were able to consume
        // in that case, mark the now-out-of-bounds indexes as modified since those points
        // were deleted
        for index in consumable.indices {
            indexSet.insert(confirmedPoints.count + predictedPoints.count + index)
        }

        return indexSet
    }
}

extension TouchPointCollection: Hashable {
    public static func == (lhs: TouchPointCollection, rhs: TouchPointCollection) -> Bool {
        return lhs.touchIdentifier == rhs.touchIdentifier
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(touchIdentifier)
    }
}
