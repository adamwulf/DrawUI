//
//  MMPen.h
//  jotuiexample
//
//  Created by Adam Wulf on 12/18/12.
//  Copyright (c) 2012 Adonit. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMDrawView, MMTouchStreamEvent;

@interface MMPen : NSObject {
    CGFloat _defaultMinSize;
    CGFloat _defaultMaxSize;

    CGFloat _minSize;
    CGFloat _maxSize;

    CGFloat _velocity;

    UIColor *_color;
}

@property(nonatomic, assign) CGFloat minSize;
@property(nonatomic, assign) CGFloat maxSize;
@property(nonatomic, strong) UIColor *color;

/**
 * the velocity of the last touch, between 0 and 1
 *
 * a value of 0 means the pen is moving less than or equal to
 * the VELOCITY_CLAMP_MIN
 * a value of 1 means the pen is moving faster than or equal to
 * the VELOCITY_CLAMP_MAX
 **/
@property(nonatomic, readonly) CGFloat velocity;

@property(nonatomic, readonly) BOOL shouldUseVelocity;

- (id)initWithMinSize:(CGFloat)_minSize andMaxSize:(CGFloat)_maxSize;

- (BOOL)willBeginStrokeWithEvent:(MMTouchStreamEvent *)coalescedTouch;
- (void)willMoveStrokeWithEvent:(MMTouchStreamEvent *)coalescedTouch;
- (void)willEndStrokeWithEvent:(MMTouchStreamEvent *)coalescedTouch shortStrokeEnding:(BOOL)shortStrokeEnding;
- (CGFloat)widthForEvent:(MMTouchStreamEvent *)coalescedTouch;
- (CGFloat)smoothnessForEvent:(MMTouchStreamEvent *)coalescedTouch;

@end
