//
//  AbstractSegment.m
//  JotUI
//
//  Created by Adam Wulf on 12/19/12.
//  Copyright (c) 2012 Milestone Made. All rights reserved.
//

#import "MMAbstractBezierPathElement.h"
#import "AbstractBezierPathElement-Protected.h"
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

- (void)adjustStartBy:(CGPoint)adjustment
{
    @throw kAbstractMethodException;
}

- (void)validateDataGivenPreviousElement:(MMAbstractBezierPathElement *)previousElement
{
    if ([self renderVersion] != kJotUIRenderVersion && !_bakedPreviousElementProps) {
        _previousWidth = previousElement.width;
        _renderVersion = kJotUIRenderVersion;
        _followsMoveTo = [previousElement isKindOfClass:[MMMoveToPathElement class]];
        _bakedPreviousElementProps = YES;
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


#pragma mark - PlistSaving

- (NSDictionary *)asDictionary
{
    return [NSDictionary dictionaryWithObjectsAndKeys:NSStringFromClass([self class]), @"class",
                                                      [NSNumber numberWithFloat:_startPoint.x], @"startPoint.x",
                                                      [NSNumber numberWithFloat:_startPoint.y], @"startPoint.y",
                                                      [NSNumber numberWithFloat:_width], @"width",
                                                      [NSNumber numberWithBool:_followsMoveTo], @"followsMoveTo",
                                                      [NSNumber numberWithFloat:_previousWidth], @"previousWidth",
                                                      [NSNumber numberWithInteger:_renderVersion], @"renderVersion",
                                                      [NSNumber numberWithBool:_bakedPreviousElementProps], @"bakedPreviousElementProps",
                                                      nil];
}

- (id)initFromDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _startPoint = CGPointMake([[dictionary objectForKey:@"startPoint.x"] floatValue], [[dictionary objectForKey:@"startPoint.y"] floatValue]);
        _width = [[dictionary objectForKey:@"width"] floatValue];
        _followsMoveTo = [[dictionary objectForKey:@"followsMoveTo"] boolValue];
        _previousWidth = [[dictionary objectForKey:@"previousWidth"] floatValue];
        _renderVersion = [[dictionary objectForKey:@"renderVersion"] integerValue];
        _bakedPreviousElementProps = [[dictionary objectForKey:@"followsMoveTo"] boolValue];
    }
    return self;
}

#pragma mark - Scaling

- (void)scaleForWidth:(CGFloat)widthRatio andHeight:(CGFloat)heightRatio
{
    _startPoint.x = _startPoint.x * widthRatio;
    _startPoint.y = _startPoint.y * heightRatio;
}

@end
