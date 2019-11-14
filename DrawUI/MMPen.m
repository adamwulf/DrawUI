//
//  MMPen.m
//  jotuiexample
//
//  Created by Adam Wulf on 12/18/12.
//  Copyright (c) 2012 Adonit. All rights reserved.
//

#import "MMPen.h"
#import "Constants.h"
#import "MMDrawnStroke.h"
#import "MMTouchVelocityGestureRecognizer.h"
#import "MMDrawView.h"
#import "MMAbstractBezierPathElement.h"

#define VELOCITY_CLAMP_MIN 20
#define VELOCITY_CLAMP_MAX 1000


@implementation MMPen {
    CGFloat _lastWidth;
    BOOL _shortStrokeEnding;
}

- (id)initWithMinSize:(CGFloat)minSize andMaxSize:(CGFloat)maxSize
{
    if (self = [super init]) {
        _minSize = minSize;
        _maxSize = maxSize;

        _defaultMinSize = _minSize;
        _defaultMaxSize = _maxSize;
        _color = [UIColor blackColor];
    }
    return self;
}

- (void)set_color:(UIColor *)color
{
    _color = [color colorWithAlphaComponent:1];
}

- (id)init
{
    return [self initWithMinSize:1.6 andMaxSize:2.7];
}

- (BOOL)shouldUseVelocity
{
    return YES;
}

#pragma mark - Setters

- (void)set_minSize:(CGFloat)minSize
{
    if (minSize < 1) {
        minSize = 1;
    }
    _minSize = minSize;
}

- (void)set_maxSize:(CGFloat)maxSize
{
    if (maxSize < 1) {
        maxSize = 1;
    }
    _maxSize = maxSize;
}

#pragma mark - MMDrawViewDelegate

/**
 * delegate method - a notification from the MMDrawView
 * that a new touch is about to be processed. we should
 * reset all of our counters/etc to base values
 */
- (BOOL)willBeginStrokeWithCoalescedTouch:(UITouch *)coalescedTouch fromTouch:(UITouch *)touch inDrawView:(MMDrawView *)drawView
{
    _shortStrokeEnding = NO;
    _velocity = 1;
    return YES;
}

/**
 * notification that the MMDrawView is about to ask for
 * width info for this touch. let's update
 * our velocity model and state info for this new touch
 */
- (void)willMoveStrokeWithCoalescedTouch:(UITouch *)coalescedTouch fromTouch:(UITouch *)touch inDrawView:(MMDrawView *)drawView
{
    _velocity = [[MMTouchVelocityGestureRecognizer sharedInstance] normalizedVelocityForTouch:touch];
}

- (void)willEndStrokeWithCoalescedTouch:(UITouch *)coalescedTouch fromTouch:(UITouch *)touch shortStrokeEnding:(BOOL)shortStrokeEnding inDrawView:(MMDrawView *)drawView
{
    _shortStrokeEnding = shortStrokeEnding;
}

/**
 * the user has moved to this new touch point, and we need
 * to specify the width of the stroke at this position
 *
 * we'll use pressure data to determine width if we can, otherwise
 * we'll fall back to use velocity data
 */
- (CGFloat)widthForCoalescedTouch:(UITouch *)coalescedTouch fromTouch:(UITouch *)touch inDrawView:(MMDrawView *)drawView
{
    if (coalescedTouch.type == UITouchTypeStylus) {
        CGFloat width = (_maxSize + _minSize) / 2.0;
        width *= coalescedTouch.force;
        if (width < _minSize)
            width = _minSize;
        if (width > _maxSize)
            width = _maxSize;

        return width;
    } else if (self.shouldUseVelocity) {
        CGFloat width = (_velocity - 1);
        if (width > 0)
            width = 0;
        width = _minSize + ABS(width) * (_maxSize - _minSize);
        if (width < 1)
            width = 1;

        if (_shortStrokeEnding) {
            return _maxSize;
        }
        
        if(_lastWidth){
            CGFloat const threadshold = .5;
            if(width - _lastWidth > threadshold){
                width = _lastWidth + threadshold;
            }else if(width - _lastWidth < -2*threadshold){
                width = _lastWidth - 2*threadshold;
            }
        }
        
        _lastWidth = width;

        return width;
    } else {
        CGFloat newWidth = _minSize + (_maxSize - _minSize) * coalescedTouch.force;
        newWidth = MAX(_minSize, MIN(_maxSize, newWidth));
        return newWidth;
    }
}

/**
 * we'll keep this pen fairly smooth, and using 0.75 gives
 * a good effect.
 *
 * 0 will be as if we just connected with straight lines,
 * 1 is as curvey as we can get,
 * > 1 is loopy
 * < 0 is knotty
 */
- (CGFloat)smoothnessForCoalescedTouch:(UITouch *)coalescedTouch fromTouch:(UITouch *)touch inDrawView:(MMDrawView *)drawView
{
    return 0.75;
}

@end
