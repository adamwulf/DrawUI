//
//  AbstractSegment.m
//  JotUI
//
//  Created by Adam Wulf on 12/19/12.
//  Copyright (c) 2012 Milestone Made. All rights reserved.
//

#import "MMAbstractBezierPathElement.h"
#import "MMAbstractBezierPathElement-Protected.h"
#import "UIColor+JotHelper.h"
#import "Constants.h"
#import "MMMoveToPathElement.h"

// This value should change if we ever decide to change how strokes are rendered, which would
// cause them to need to re-calculate their cached vertex buffer
#define kJotUIRenderVersion 1


@implementation MMAbstractBezierPathElement

- (id)initWithStart:(CGPoint)point
{
    if (self = [super init]) {
        _startPoint = point;
        _identifier = [[NSUUID UUID] UUIDString];
    }
    return self;
}

/**
 * the length of the drawn segment. if it is a
 * curve, then it is the travelled distance along
 * the curve, not the linear distance between start
 * and end points
 */
- (CGFloat)lengthOfElement
{
    @throw kAbstractMethodException;
}

- (CGFloat)angleOfStart
{
    @throw kAbstractMethodException;
}

- (CGFloat)angleOfEnd
{
    @throw kAbstractMethodException;
}

- (CGRect)bounds
{
    @throw kAbstractMethodException;
}

- (CGPoint)endPoint
{
    @throw kAbstractMethodException;
}

- (UIBezierPath *)borderPath
{
    @throw kAbstractMethodException;
}

- (void)adjustStartBy:(CGPoint)adjustment
{
    @throw kAbstractMethodException;
}

- (BOOL)followsMoveTo
{
    return [_previousElement isKindOfClass:[MMMoveToPathElement class]];
}

- (void)validateDataGivenPreviousElement:(MMAbstractBezierPathElement *)previousElement
{
    if ([self renderVersion] != kJotUIRenderVersion && !_previousElement) {
        _previousElement = previousElement;
        _previousElement->_nextElement = self;
        _renderVersion = kJotUIRenderVersion;
    } else {
        @throw [NSException exceptionWithName:@"RevalidateElementException" reason:@"Cannot revalidate previous element" userInfo:nil];
    }
}

- (UIBezierPath *)bezierPathSegment
{
    @throw kAbstractMethodException;
}


- (CGFloat)angleBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2
{
    // Provides a directional bearing from point2 to the given point.
    // standard cartesian plain coords: Y goes up, X goes right
    // result returns radians, -180 to 180 ish: 0 degrees = up, -90 = left, 90 = right
    return atan2f(point1.y - point2.y, point1.x - point2.x) + M_PI_2;
}

#pragma mark - Scaling

- (void)scaleForWidth:(CGFloat)widthRatio andHeight:(CGFloat)heightRatio
{
    _startPoint.x = _startPoint.x * widthRatio;
    _startPoint.y = _startPoint.y * heightRatio;
}

#pragma mark - Events

- (void)clearPathCaches
{
    // noop
}

- (void)updateWithEvent:(MMTouchStreamEvent *)event width:(CGFloat)width
{
    if ([[[self events] firstObject] expectsForceUpdate]) {
        _width = width;
    }

    [self clearPathCaches];
    [[self nextElement] clearPathCaches];

    _updated = YES;
}

- (BOOL)isPrediction
{
    return [[[self events] firstObject] isPrediction];
}

@end
