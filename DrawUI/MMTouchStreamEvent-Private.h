//
//  MMTouchStreamEvent-Private.h
//  DrawUI
//
//  Created by Adam Wulf on 2/21/20.
//  Copyright © 2020 Milestone Made. All rights reserved.
//


@interface MMTouchStreamEvent ()

#pragma mark - Properties

/// A completely unique identifier per event, even for events built from
/// the same touch or coalescedTouch
@property(nonatomic, strong) NSString *identifier;

/// An identifier unique to the touch that created this event. Events with the same
/// touch will also have the same touchIdentifier
@property(nonatomic, strong) NSString *touchIdentifier;
@property(nonatomic, assign) NSTimeInterval timestamp;
@property(nonatomic, assign) UITouchType type;
@property(nonatomic, assign) UITouchPhase phase;
@property(nonatomic, assign) CGFloat force;
@property(nonatomic, assign) CGFloat maximumPossibleForce;
@property(nonatomic, assign) CGFloat altitudeAngle;
@property(nonatomic, assign) CGVector azimuthUnitVector;
@property(nonatomic, assign) CGFloat azimuth;
@property(nonatomic, assign) CGFloat velocity;
@property(nonatomic, assign) CGFloat majorRadius;
@property(nonatomic, assign) CGFloat majorRadiusTolerance;
@property(nonatomic, assign) CGPoint location;
@property(nonatomic, strong) NSNumber *estimationUpdateIndex;
@property(nonatomic, assign) UITouchProperties estimatedProperties;
@property(nonatomic, assign)
    UITouchProperties estimatedPropertiesExpectingUpdates;
@property(nonatomic, assign, getter=isUpdate) BOOL update;
@property(nonatomic, assign, getter=isPrediction) BOOL prediction;

#pragma mark - Non-Coded properties

@property(nonatomic, weak) UIView *inView;

@end
