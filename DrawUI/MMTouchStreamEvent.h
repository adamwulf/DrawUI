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

@interface MMTouchStreamEvent : NSObject

+ (MMTouchStreamEvent *)eventWithCoalescedTouch:(UITouch *)coalescedTouch touch:(UITouch *)touch velocity:(CGFloat)velocity isUpdate:(BOOL)update isPrediction:(BOOL)prediction;

/// use NSObject, as the touch is unique and consistent, but its values are
/// stale
/// so it's useful to track a touch through events, but not useful to introspect
@property(nonatomic, strong) NSObject *coalescedTouch;
@property(nonatomic, strong) NSObject *touch;
@property(nonatomic, strong) NSString *uuid;
@property(nonatomic, assign) NSTimeInterval timestamp;
@property(nonatomic, assign) UITouchType type;
@property(nonatomic, assign) UITouchPhase phase;
@property(nonatomic, assign) CGFloat force;
@property(nonatomic, assign) CGFloat maximumPossibleForce;
@property(nonatomic, assign) CGFloat altitudeAngle;
@property(nonatomic, assign) CGFloat azimuth;
@property(nonatomic, assign) CGFloat velocity;
@property(nonatomic, assign) CGFloat majorRadius;
@property(nonatomic, assign) CGFloat majorRadiusTolerance;
@property(nonatomic, assign) CGPoint location;
@property(nonatomic, weak) UIView *inView;
@property(nonatomic, strong) NSNumber *estimationUpdateIndex;
@property(nonatomic, assign) UITouchProperties estimatedProperties;
@property(nonatomic, assign)
    UITouchProperties estimatedPropertiesExpectingUpdates;
@property(nonatomic, assign, getter=isUpdate) BOOL update;
@property(nonatomic, assign, getter=isPrediction) BOOL prediction;

#pragma mark - Computed Properties

@property(nonatomic, readonly) BOOL expectsLocationUpdate;
@property(nonatomic, readonly) BOOL expectsForceUpdate;
@property(nonatomic, readonly) BOOL expectsAzimuthUpdate;

#pragma mark - Public Methods

- (BOOL)matchesEvent:(MMTouchStreamEvent *)otherEvent;

@end

NS_ASSUME_NONNULL_END
