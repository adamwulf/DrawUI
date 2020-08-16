//
//  TouchStreamEvent.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/10/20.
//

import UIKit

class TouchStreamEvent {

    /// A completely unique identifier per event, even for events built from
    /// the same touch or coalescedTouch
    let identifier: String

    /// An identifier unique to the touch that created this event. Events with the same
    /// touch will also have the same touchIdentifier
    let touchIdentifier: String
    let timestamp: TimeInterval
    let type: UITouch.TouchType
    let phase: UITouch.Phase
    let force: CGFloat
    let maximumPossibleForce: CGFloat
    let altitudeAngle: CGFloat
    let azimuthUnitVector: CGVector
    let azimuth: CGFloat
    let velocity: CGFloat
    let majorRadius: CGFloat
    let majorRadiusTolerance: CGFloat
    let location: CGPoint
    let estimationUpdateIndex: NSNumber?
    let estimatedProperties: UITouch.Properties
    let estimatedPropertiesExpectingUpdates: UITouch.Properties
    let isUpdate: Bool
    let isPrediction: Bool

    // MARK: - Non-coded properties

    let view: UIView?

    // MARK: - Computed Properties

    var expectsLocationUpdate: Bool {
        return estimatedPropertiesExpectingUpdates.contains(UITouch.Properties.location)
    }

    var expectsForceUpdate: Bool {
        return estimatedPropertiesExpectingUpdates.contains(UITouch.Properties.force)
    }

    var expectsAzimuthUpdate: Bool {
        return estimatedPropertiesExpectingUpdates.contains(UITouch.Properties.azimuth)
    }
//    + (MMTouchStreamEvent *)eventWithCoalescedTouch:(UITouch *)coalescedTouch touch:(UITouch *)touch velocity:(CGFloat)velocity isUpdate:(BOOL)update isPrediction:(BOOL)prediction

    convenience init(coalescedTouch: UITouch, touch: UITouch, velocity: CGFloat, isUpdate: Bool, isPrediction: Bool) {
        self.init(identifier: UUID.init().uuidString,
                  touchIdentifier: touch.identifer,
                  timestamp: coalescedTouch.timestamp,
                  type: coalescedTouch.type,
                  phase: coalescedTouch.phase,
                  force: coalescedTouch.force,
                  maximumPossibleForce: coalescedTouch.maximumPossibleForce,
                  altitudeAngle: coalescedTouch.altitudeAngle,
                  azimuthUnitVector: coalescedTouch.azimuthUnitVector(in: coalescedTouch.view),
                  azimuth: coalescedTouch.azimuthAngle(in: coalescedTouch.view),
                  velocity: velocity,
                  majorRadius: coalescedTouch.majorRadius,
                  majorRadiusTolerance: coalescedTouch.majorRadiusTolerance,
                  location: coalescedTouch.location(in: coalescedTouch.view),
                  estimationUpdateIndex: coalescedTouch.estimationUpdateIndex,
                  estimatedProperties: coalescedTouch.estimatedProperties,
                  estimatedPropertiesExpectingUpdates: coalescedTouch.estimatedPropertiesExpectingUpdates,
                  isUpdate: isUpdate,
                  isPrediction: isPrediction,
                  in: coalescedTouch.view)
    }

    init(identifier: String,
         touchIdentifier: String,
         timestamp: TimeInterval,
         type: UITouch.TouchType,
         phase: UITouch.Phase,
         force: CGFloat,
         maximumPossibleForce: CGFloat,
         altitudeAngle: CGFloat,
         azimuthUnitVector: CGVector,
         azimuth: CGFloat,
         velocity: CGFloat,
         majorRadius: CGFloat,
         majorRadiusTolerance: CGFloat,
         location: CGPoint,
         estimationUpdateIndex: NSNumber?,
         estimatedProperties: UITouch.Properties,
         estimatedPropertiesExpectingUpdates: UITouch.Properties,
         isUpdate: Bool,
         isPrediction: Bool,
         in view: UIView?) {
        self.identifier = identifier
        self.touchIdentifier = touchIdentifier
        self.timestamp = timestamp
        self.type = type
        self.phase = phase
        self.force = force
        self.maximumPossibleForce = maximumPossibleForce
        self.altitudeAngle = altitudeAngle
        self.azimuthUnitVector = azimuthUnitVector
        self.azimuth = azimuth
        self.velocity = velocity
        self.majorRadius = majorRadius
        self.majorRadiusTolerance = majorRadiusTolerance
        self.location = location
        self.estimationUpdateIndex = estimationUpdateIndex
        self.estimatedProperties = estimatedProperties
        self.estimatedPropertiesExpectingUpdates = estimatedPropertiesExpectingUpdates
        self.isUpdate = isUpdate
        self.isPrediction = isPrediction
        self.view = view
    }

    func isSameTouchAs(event: TouchStreamEvent) -> Bool {
        return touchIdentifier == event.touchIdentifier
    }
}
