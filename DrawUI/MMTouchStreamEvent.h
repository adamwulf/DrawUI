//
//  MMTouchStreamEvent.h
//  DrawUI
//
//  Created by Adam Wulf on 11/15/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMPen.h"

NS_ASSUME_NONNULL_BEGIN


@interface MMTouchStreamEvent : NSObject <NSCopying, NSSecureCoding>

+ (MMTouchStreamEvent *)eventWithCoalescedTouch:(UITouch *)coalescedTouch touch:(UITouch *)touch velocity:(CGFloat)velocity isUpdate:(BOOL)update isPrediction:(BOOL)prediction;

#pragma mark - Properties

/// A completely unique identifier per event, even for events built from
/// the same touch or coalescedTouch
@property(nonatomic, strong, readonly) NSString *identifier;

/// An identifier unique to the touch that created this event. Events with the same
/// touch will also have the same touchIdentifier
@property(nonatomic, strong, readonly) NSString *touchIdentifier;
@property(nonatomic, assign, readonly) NSTimeInterval timestamp;
@property(nonatomic, assign, readonly) UITouchType type;
@property(nonatomic, assign, readonly) UITouchPhase phase;
@property(nonatomic, assign, readonly) CGFloat force;
@property(nonatomic, assign, readonly) CGFloat maximumPossibleForce;
@property(nonatomic, assign, readonly) CGFloat altitudeAngle;
@property(nonatomic, assign, readonly) CGVector azimuthUnitVector;
@property(nonatomic, assign, readonly) CGFloat azimuth;
@property(nonatomic, assign, readonly) CGFloat velocity;
@property(nonatomic, assign, readonly) CGFloat majorRadius;
@property(nonatomic, assign, readonly) CGFloat majorRadiusTolerance;
@property(nonatomic, assign, readonly) CGPoint location;
@property(nonatomic, strong, readonly) NSNumber *estimationUpdateIndex;
@property(nonatomic, assign, readonly) UITouchProperties estimatedProperties;
@property(nonatomic, assign, readonly)
    UITouchProperties estimatedPropertiesExpectingUpdates;
@property(nonatomic, assign, getter=isUpdate, readonly) BOOL update;
@property(nonatomic, assign, getter=isPrediction, readonly) BOOL prediction;

#pragma mark - Non-Coded properties

@property(nonatomic, weak, readonly) UIView *inView;

#pragma mark - Computed Properties

@property(nonatomic, readonly) BOOL expectsLocationUpdate;
@property(nonatomic, readonly) BOOL expectsForceUpdate;
@property(nonatomic, readonly) BOOL expectsAzimuthUpdate;

#pragma mark - Public Methods

- (BOOL)isSameTouchAsEvent:(MMTouchStreamEvent *)otherEvent;

@end

NS_ASSUME_NONNULL_END
