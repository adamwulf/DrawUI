//
//  AbstractSegment.m
//  MMDrawUI
//
//  Created by Adam Wulf on 12/19/12.
//  Copyright (c) 2012 Milestone Made. All rights reserved.
//

#import "MMAbstractBezierPathElement.h"
#import "MMAbstractBezierPathElement-Protected.h"
#import "UIColor+MMDrawUI.h"
#import "Constants.h"
#import "MMMoveToPathElement.h"

// This value should change if we ever decide to change how strokes are rendered, which would
// cause them to need to re-calculate their cached vertex buffer
#define kDrawUIRenderVersion 1


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

- (void)configurePreviousElement:(MMAbstractBezierPathElement *)previousElement
{
    if ([self renderVersion] != kDrawUIRenderVersion && !_previousElement) {
        _previousElement = previousElement;
        _previousElement->_nextElement = self;
        _renderVersion = kDrawUIRenderVersion;
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

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        _identifier = [coder decodeObjectOfClass:[NSString class] forKey:@"identifier"];
        _startPoint = [coder decodeCGPointForKey:@"startPoint"];
        _width = [coder decodeDoubleForKey:@"width"];
        _previousElement = [coder decodeObjectOfClasses:[NSSet setWithObject:[MMAbstractBezierPathElement class]] forKey:@"previousElement"];
        _nextElement = [coder decodeObjectOfClasses:[NSSet setWithObject:[MMAbstractBezierPathElement class]] forKey:@"nextElement"];
        _renderVersion = [coder decodeIntegerForKey:@"renderVersion"];
        _updated = [coder decodeBoolForKey:@"updated"];
        _version = [coder decodeIntegerForKey:@"version"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[self identifier] forKey:@"identifier"];
    [coder encodeCGPoint:_startPoint forKey:@"startPoint"];
    [coder encodeDouble:_width forKey:@"width"];
    [coder encodeObject:_previousElement forKey:@"previousElement"];
    [coder encodeObject:_nextElement forKey:@"nextElement"];
    [coder encodeInteger:_renderVersion forKey:@"renderVersion"];
    [coder encodeBool:_updated forKey:@"updated"];
    [coder encodeInteger:_version forKey:@"version"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    MMAbstractBezierPathElement *ret = [[[self class] allocWithZone:zone] init];

    ret->_identifier = _identifier;
    ret->_startPoint = _startPoint;
    ret->_width = _width;
    ret->_updated = _updated;
    ret->_version = _version;
    ret->_events = [_events copy];

    return ret;
}

@end
