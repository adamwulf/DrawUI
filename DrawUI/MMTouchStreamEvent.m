//
//  MMTouchStreamEvent.m
//  DrawUI
//
//  Created by Adam Wulf on 11/15/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "MMTouchStreamEvent.h"

@implementation MMTouchStreamEvent

+ (MMTouchStreamEvent *)eventWithTouch:(UITouch *)touch velocity:(CGFloat)velocity isUpdate:(BOOL)update
{
    MMTouchStreamEvent *event = [[MMTouchStreamEvent alloc] init];

    [event setIdentifier:[[NSUUID UUID] UUIDString]];
    [event setTouch:touch];
    [event setTimestamp:[touch timestamp]];
    [event setType:[touch type]];
    [event setPhase:[touch phase]];
    [event setForce:[touch force]];
    [event setMaximumPossibleForce:[touch maximumPossibleForce]];
    [event setAzimuth:[touch azimuthAngleInView:[touch view]]];
    [event setVelocity:velocity];
    [event setMajorRadius:[touch majorRadius]];
    [event setMajorRadiusTolerance:[touch majorRadiusTolerance]];
    [event setLocation:[touch preciseLocationInView:[touch view]]];
    [event setInView:[touch view]];
    [event setEstimationUpdateIndex:[touch estimationUpdateIndex]];
    [event setEstimatedProperties:[touch estimatedProperties]];
    [event setEstimatedPropertiesExpectingUpdates:[touch estimatedPropertiesExpectingUpdates]];
    [event setUpdate:update];

    return event;
}

@end
