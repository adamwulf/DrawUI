//
//  MMTouchStreamEvent.m
//  DrawUI
//
//  Created by Adam Wulf on 11/15/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "MMTouchStreamEvent.h"
#import "UITouch+MMDrawUI.h"
#import "Constants.h"
#import "MMTouchStreamEvent-Private.h"


@implementation MMTouchStreamEvent

+ (MMTouchStreamEvent *)eventWithCoalescedTouch:(UITouch *)coalescedTouch touch:(UITouch *)touch velocity:(CGFloat)velocity isUpdate:(BOOL)update isPrediction:(BOOL)prediction
{
    MMTouchStreamEvent *event = [[MMTouchStreamEvent alloc] init];

    [event setIdentifier:[[NSUUID UUID] UUIDString]];
    [event setTouchIdentifier:[touch identifier]];
    [event setTimestamp:[coalescedTouch timestamp]];
    [event setType:[coalescedTouch type]];
    [event setPhase:[coalescedTouch phase]];
    [event setForce:[coalescedTouch force]];
    [event setMaximumPossibleForce:[coalescedTouch maximumPossibleForce]];
    [event setAltitudeAngle:[coalescedTouch altitudeAngle]];
    [event setAzimuthUnitVector:[coalescedTouch azimuthUnitVectorInView:[coalescedTouch view]]];
    [event setAzimuth:[coalescedTouch azimuthAngleInView:[coalescedTouch view]]];
    [event setVelocity:velocity];
    [event setMajorRadius:[coalescedTouch majorRadius]];
    [event setMajorRadiusTolerance:[coalescedTouch majorRadiusTolerance]];
    [event setLocation:[coalescedTouch preciseLocationInView:[coalescedTouch view]]];
    [event setInView:[coalescedTouch view]];
    [event setEstimationUpdateIndex:[coalescedTouch estimationUpdateIndex]];
    [event setEstimatedProperties:[coalescedTouch estimatedProperties]];
    [event setEstimatedPropertiesExpectingUpdates:[coalescedTouch estimatedPropertiesExpectingUpdates]];
    [event setUpdate:update];
    [event setPrediction:prediction];

    return event;
}

#pragma mark - Computed Properties

- (BOOL)expectsLocationUpdate
{
    return [self estimatedPropertiesExpectingUpdates] & UITouchPropertyLocation;
}

- (BOOL)expectsForceUpdate
{
    return [self estimatedPropertiesExpectingUpdates] & UITouchPropertyForce;
}

- (BOOL)expectsAzimuthUpdate
{
    return [self estimatedPropertiesExpectingUpdates] & UITouchPropertyAzimuth;
}

#pragma mark - Public Methods

- (BOOL)isSameTouchAsEvent:(MMTouchStreamEvent *)otherEvent
{
    return [[self touchIdentifier] isEqual:[otherEvent touchIdentifier]];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    MMTouchStreamEvent *ret = [[self class] allocWithZone:zone];

    [ret setIdentifier:[self identifier]];
    [ret setTouchIdentifier:[self touchIdentifier]];
    [ret setTimestamp:[self timestamp]];
    [ret setType:[self type]];
    [ret setPhase:[self phase]];
    [ret setForce:[self force]];
    [ret setMaximumPossibleForce:[self maximumPossibleForce]];
    [ret setAltitudeAngle:[self altitudeAngle]];
    [ret setAzimuthUnitVector:[self azimuthUnitVector]];
    [ret setAzimuth:[self azimuth]];
    [ret setVelocity:[self velocity]];
    [ret setMajorRadius:[self majorRadius]];
    [ret setMajorRadiusTolerance:[self majorRadiusTolerance]];
    [ret setLocation:[self location]];
    [ret setInView:[self inView]];
    [ret setEstimationUpdateIndex:[self estimationUpdateIndex]];
    [ret setEstimatedProperties:[self estimatedProperties]];
    [ret setEstimatedPropertiesExpectingUpdates:[self estimatedPropertiesExpectingUpdates]];
    [ret setUpdate:[self isUpdate]];
    [ret setPrediction:[self isPrediction]];

    return ret;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        _identifier = [coder decodeObjectOfClass:[NSString class] forKey:PROPERTYNAME(identifier)];
        _touchIdentifier = [coder decodeObjectOfClass:[NSString class] forKey:PROPERTYNAME(touchIdentifier)];
        _timestamp = [coder decodeDoubleForKey:PROPERTYNAME(timestamp)];
        _type = [coder decodeIntegerForKey:PROPERTYNAME(type)];
        _phase = [coder decodeIntegerForKey:PROPERTYNAME(phase)];
        _force = [coder decodeDoubleForKey:PROPERTYNAME(force)];
        _maximumPossibleForce = [coder decodeDoubleForKey:PROPERTYNAME(maximumPossibleForce)];
        _altitudeAngle = [coder decodeDoubleForKey:PROPERTYNAME(altitudeAngle)];
        _azimuthUnitVector = [coder decodeCGVectorForKey:PROPERTYNAME(azimuthUnitVector)];
        _azimuth = [coder decodeDoubleForKey:PROPERTYNAME(azimuth)];
        _velocity = [coder decodeDoubleForKey:PROPERTYNAME(velocity)];
        _majorRadius = [coder decodeDoubleForKey:PROPERTYNAME(majorRadius)];
        _majorRadiusTolerance = [coder decodeDoubleForKey:PROPERTYNAME(majorRadiusTolerance)];
        _location = [coder decodeCGPointForKey:PROPERTYNAME(location)];
        _estimationUpdateIndex = [coder decodeObjectOfClass:[NSNumber class] forKey:PROPERTYNAME(estimationUpdateIndex)];
        _estimatedProperties = [coder decodeIntegerForKey:PROPERTYNAME(estimatedProperties)];
        _estimatedPropertiesExpectingUpdates = [coder decodeIntegerForKey:PROPERTYNAME(estimatedPropertiesExpectingUpdates)];
        _update = [coder decodeBoolForKey:PROPERTYNAME(isUpdate)];
        _prediction = [coder decodeBoolForKey:PROPERTYNAME(isPrediction)];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_identifier forKey:PROPERTYNAME(identifier)];
    [coder encodeObject:_touchIdentifier forKey:PROPERTYNAME(touchIdentifier)];
    [coder encodeDouble:_timestamp forKey:PROPERTYNAME(timestamp)];
    [coder encodeInteger:_type forKey:PROPERTYNAME(type)];
    [coder encodeInteger:_phase forKey:PROPERTYNAME(phase)];
    [coder encodeDouble:_force forKey:PROPERTYNAME(force)];
    [coder encodeDouble:_maximumPossibleForce forKey:PROPERTYNAME(maximumPossibleForce)];
    [coder encodeDouble:_altitudeAngle forKey:PROPERTYNAME(altitudeAngle)];
    [coder encodeCGVector:_azimuthUnitVector forKey:PROPERTYNAME(azimuthUnitVector)];
    [coder encodeDouble:_azimuth forKey:PROPERTYNAME(azimuth)];
    [coder encodeDouble:_velocity forKey:PROPERTYNAME(velocity)];
    [coder encodeDouble:_majorRadius forKey:PROPERTYNAME(majorRadius)];
    [coder encodeDouble:_majorRadiusTolerance forKey:PROPERTYNAME(majorRadiusTolerance)];
    [coder encodeCGPoint:_location forKey:PROPERTYNAME(location)];
    [coder encodeObject:_estimationUpdateIndex forKey:PROPERTYNAME(estimationUpdateIndex)];
    [coder encodeInteger:_estimatedProperties forKey:PROPERTYNAME(estimatedProperties)];
    [coder encodeInteger:_estimatedPropertiesExpectingUpdates forKey:PROPERTYNAME(estimatedPropertiesExpectingUpdates)];
    [coder encodeBool:_update forKey:PROPERTYNAME(isUpdate)];
    [coder encodeBool:_prediction forKey:PROPERTYNAME(isPrediction)];
}

@end
