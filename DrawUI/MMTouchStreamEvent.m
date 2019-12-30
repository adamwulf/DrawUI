//
//  MMTouchStreamEvent.m
//  DrawUI
//
//  Created by Adam Wulf on 11/15/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "MMTouchStreamEvent.h"
#import "UITouch+MMDrawUI.h"

@implementation MMTouchStreamEvent

+ (MMTouchStreamEvent *)eventWithCoalescedTouch:(UITouch *)coalescedTouch touch:(UITouch *)touch velocity:(CGFloat)velocity isUpdate:(BOOL)update isPrediction:(BOOL)prediction
{
    MMTouchStreamEvent *event = [[MMTouchStreamEvent alloc] init];

    [event setUuid:[[NSUUID UUID] UUIDString]];
    [event setTouchIdentifier:[touch identifier]];
    [event setTimestamp:[coalescedTouch timestamp]];
    [event setType:[coalescedTouch type]];
    [event setPhase:[coalescedTouch phase]];
    [event setForce:[coalescedTouch force]];
    [event setMaximumPossibleForce:[coalescedTouch maximumPossibleForce]];
    [event setAltitudeAngle:[coalescedTouch altitudeAngle]];
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

- (BOOL)matchesEvent:(MMTouchStreamEvent *)otherEvent
{
    return [[self touchIdentifier] isEqual:[otherEvent touchIdentifier]];
}

@end
