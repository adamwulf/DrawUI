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
#import "MMTouchStreamEvent.h"

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

#pragma mark - Events

- (BOOL)willBeginStrokeWithEvent:(MMTouchStreamEvent *)touchEvent
{
    _shortStrokeEnding = NO;
    _velocity = 1;
    return YES;
}

- (void)willMoveStrokeWithEvent:(MMTouchStreamEvent *)touchEvent
{
    _velocity = [touchEvent velocity];
}

- (void)willEndStrokeWithEvent:(MMTouchStreamEvent *)touchEvent shortStrokeEnding:(BOOL)shortStrokeEnding
{
    _shortStrokeEnding = shortStrokeEnding;
}

- (CGFloat)widthForEvent:(MMTouchStreamEvent *)touchEvent
{
    if (touchEvent.type == UITouchTypeStylus) {
        CGFloat width = (_maxSize + _minSize) / 2.0;
        width *= touchEvent.force;
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

        if (_lastWidth) {
            CGFloat const threadshold = .5;
            if (width - _lastWidth > threadshold) {
                width = _lastWidth + threadshold;
            } else if (width - _lastWidth < -2 * threadshold) {
                width = _lastWidth - 2 * threadshold;
            }
        }

        _lastWidth = width;

        return width;
    } else {
        CGFloat newWidth = _minSize + (_maxSize - _minSize) * touchEvent.force;
        newWidth = MAX(_minSize, MIN(_maxSize, newWidth));
        return newWidth;
    }
}

- (CGFloat)smoothnessForEvent:(MMTouchStreamEvent *)coalescedTouch
{
    return 0.75;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        _defaultMinSize = [coder decodeDoubleForKey:@"defaultMinSize"];
        _defaultMaxSize = [coder decodeDoubleForKey:@"defaultMaxSize"];
        _minSize = [coder decodeDoubleForKey:@"minSize"];
        _maxSize = [coder decodeDoubleForKey:@"maxSize"];
        _velocity = [coder decodeDoubleForKey:@"velocity"];
        _color = [coder decodeObjectOfClass:[UIColor class] forKey:@"color"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeDouble:_defaultMinSize forKey:@"defaultMinSize"];
    [coder encodeDouble:_defaultMaxSize forKey:@"defaultMaxSize"];
    [coder encodeDouble:_minSize forKey:@"minSize"];
    [coder encodeDouble:_maxSize forKey:@"maxSize"];
    [coder encodeDouble:_velocity forKey:@"velocity"];
    [coder encodeObject:_color forKey:@"color"];
}

@end
