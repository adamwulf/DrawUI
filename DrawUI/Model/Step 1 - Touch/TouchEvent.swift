//
//  TouchEvent.swift
//  DrawUI
//
//  Created by Adam Wulf on 8/10/20.
//

import UIKit

public class TouchEvent {

    /// A completely unique identifier per event, even for events built from
    /// the same touch or coalescedTouch
    public let identifier: String

    /// An identifier unique to the touch that created this event. Events with the same
    /// touch will also have the same touchIdentifier
    public let touchIdentifier: String
    public var pointIdentifier: String {
        if let estimationUpdateIndex = estimationUpdateIndex {
            return touchIdentifier + ":\(estimationUpdateIndex)"
        } else {
            return touchIdentifier + ":" + identifier
        }
    }
    public let timestamp: TimeInterval
    public let type: UITouch.TouchType
    public let phase: UITouch.Phase
    public let force: CGFloat
    public let maximumPossibleForce: CGFloat
    public let altitudeAngle: CGFloat
    public let azimuthUnitVector: CGVector
    public let azimuth: CGFloat
    public let majorRadius: CGFloat
    public let majorRadiusTolerance: CGFloat
    public let location: CGPoint
    public let estimationUpdateIndex: NSNumber?
    public let estimatedProperties: UITouch.Properties
    public let estimatedPropertiesExpectingUpdates: UITouch.Properties
    public let isUpdate: Bool
    public let isPrediction: Bool

    // MARK: - Non-coded properties

    public let view: UIView?

    // MARK: - Computed Properties

    public var expectsLocationUpdate: Bool {
        return estimatedPropertiesExpectingUpdates.contains(UITouch.Properties.location)
    }

    public var expectsForceUpdate: Bool {
        return estimatedPropertiesExpectingUpdates.contains(UITouch.Properties.force)
    }

    public var expectsAzimuthUpdate: Bool {
        return estimatedPropertiesExpectingUpdates.contains(UITouch.Properties.azimuth)
    }

    public var expectsUpdate: Bool {
        return expectsForceUpdate || expectsAzimuthUpdate || expectsLocationUpdate
    }

    public convenience init(coalescedTouch: UITouch, touch: UITouch, isUpdate: Bool, isPrediction: Bool) {
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

    public init(identifier: String,
         touchIdentifier: String,
         timestamp: TimeInterval,
         type: UITouch.TouchType,
         phase: UITouch.Phase,
         force: CGFloat,
         maximumPossibleForce: CGFloat,
         altitudeAngle: CGFloat,
         azimuthUnitVector: CGVector,
         azimuth: CGFloat,
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

    public convenience init(touchIdentifier: String,
                     type: UITouch.TouchType = .direct,
                     phase: UITouch.Phase,
                     force: CGFloat = 1,
                     location: CGPoint,
                     estimationUpdateIndex: NSNumber? = nil,
                     estimatedProperties: UITouch.Properties,
                     estimatedPropertiesExpectingUpdates: UITouch.Properties,
                     isUpdate: Bool,
                     isPrediction: Bool) {
        self.init(identifier: UUID().uuidString,
             touchIdentifier: touchIdentifier,
             timestamp: Date().timeIntervalSinceReferenceDate,
             type: type,
             phase: phase,
             force: force,
             maximumPossibleForce: 1,
             altitudeAngle: 0,
             azimuthUnitVector: CGVector.zero,
             azimuth: 0,
             majorRadius: 1,
             majorRadiusTolerance: 1,
             location: location,
             estimationUpdateIndex: estimationUpdateIndex,
             estimatedProperties: estimatedProperties,
             estimatedPropertiesExpectingUpdates: estimatedPropertiesExpectingUpdates,
             isUpdate: isUpdate,
             isPrediction: isPrediction,
             in: nil)
    }

    public func isSameTouchAs(event: TouchEvent) -> Bool {
        return touchIdentifier == event.touchIdentifier
    }
}

extension TouchEvent: Hashable {
    public static func == (lhs: TouchEvent, rhs: TouchEvent) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}
