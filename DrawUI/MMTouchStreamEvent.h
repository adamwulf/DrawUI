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

+ (MMTouchStreamEvent *)eventWithTouch:(UITouch *)touch velocity:(CGFloat)velocity isUpdate:(BOOL)update;

/// use NSObject, as the touch is unique and consistent, but its values are
/// stale
/// so it's useful to track a touch through events, but not useful to introspect
@property(nonatomic, strong) NSObject *touch;
@property(nonatomic, strong) NSObject *identifier;
@property(nonatomic, assign) NSTimeInterval timestamp;
@property(nonatomic, assign) UITouchType type;
@property(nonatomic, assign) UITouchPhase phase;
@property(nonatomic, assign) CGFloat force;
@property(nonatomic, assign) CGFloat maximumPossibleForce;
@property(nonatomic, assign) CGFloat azimuth;
@property(nonatomic, assign) CGFloat velocity;
@property(nonatomic, assign) CGFloat majorRadius;
@property(nonatomic, assign) CGFloat majorRadiusTolerance;
@property(nonatomic, assign) CGPoint location;
@property(nonatomic, assign) UIView *inView;
@property(nonatomic, assign) NSNumber *estimationUpdateIndex;
@property(nonatomic, assign) UITouchProperties estimatedProperties;
@property(nonatomic, assign)
    UITouchProperties estimatedPropertiesExpectingUpdates;
@property(nonatomic, assign, getter=isUpdate) BOOL update;

@end

NS_ASSUME_NONNULL_END
