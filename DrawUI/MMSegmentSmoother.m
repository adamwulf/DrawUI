//
//  MMSegmentSmoother.m
//  JotUI
//
//  Created by Adam Wulf on 12/19/12.
//  Copyright (c) 2012 Milestone Made. All rights reserved.
//

#import "MMSegmentSmoother.h"
#import "MMAbstractBezierPathElement.h"
#import "MMAbstractBezierPathElement-Protected.h"
#import "MMCurveToPathElement.h"
#import "MMMoveToPathElement.h"


@implementation MMSegmentSmoother

- (id)init
{
    if (self = [super init]) {
        _point0 = CGPointMake(-CGFLOAT_MAX, -CGFLOAT_MAX);
        _point1 = CGPointMake(-CGFLOAT_MAX, -CGFLOAT_MAX); // previous previous point
        _point2 = CGPointMake(-CGFLOAT_MAX, -CGFLOAT_MAX); // previous touch point
        _point3 = CGPointMake(-CGFLOAT_MAX, -CGFLOAT_MAX);
    }
    return self;
}

/**
 * This method will add the point and try to interpolate a
 * curve/line/moveto segment from this new point and the points
 * that have come before.
 *
 * The first two points will generate the first moveto segment,
 * and subsequent points after that will generate curve
 * segments
 *
 * code modified from: http://www.effectiveui.com/blog/2011/12/02/how-to-build-a-simple-painting-app-for-ios/
 */
- (MMAbstractBezierPathElement *)addPoint:(CGPoint)inPoint andSmoothness:(CGFloat)smoothFactor;
{
    // update the points
    _point0 = _point1;
    _point1 = _point2;
    _point2 = _point3;
    _point3 = inPoint;

    MMAbstractBezierPathElement *ele;

    // determine if we need a new segment
    if (_point1.x > -CGFLOAT_MAX) {
        double x0 = (_point0.x > -CGFLOAT_MAX) ? _point0.x : _point1.x; //after 4 touches we should have a back anchor point, if not, use the current anchor point
        double y0 = (_point0.y > -CGFLOAT_MAX) ? _point0.y : _point1.y; //after 4 touches we should have a back anchor point, if not, use the current anchor point
        double x1 = _point1.x;
        double y1 = _point1.y;
        double x2 = _point2.x;
        double y2 = _point2.y;
        double x3 = _point3.x;
        double y3 = _point3.y;

        // Assume we need to calculate the control
        // points between (x1,y1) and (x2,y2).
        // Then x0,y0 - the previous vertex,
        //      x3,y3 - the next one.

        double xc1 = (x0 + x1) / 2.0;
        double yc1 = (y0 + y1) / 2.0;
        double xc2 = (x1 + x2) / 2.0;
        double yc2 = (y1 + y2) / 2.0;
        double xc3 = (x2 + x3) / 2.0;
        double yc3 = (y2 + y3) / 2.0;

        double len1 = sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0));
        double len2 = sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
        double len3 = sqrt((x3 - x2) * (x3 - x2) + (y3 - y2) * (y3 - y2));

        double k1 = len1 / (len1 + len2);
        double k2 = len2 / (len2 + len3);

        double xm1 = xc1 + (xc2 - xc1) * k1;
        double ym1 = yc1 + (yc2 - yc1) * k1;

        double xm2 = xc2 + (xc3 - xc2) * k2;
        double ym2 = yc2 + (yc3 - yc2) * k2;
        double smooth_value = smoothFactor;

        // Resulting control points. Here smooth_value is mentioned
        // above coefficient K whose value should be in range [0...1].
        float ctrl1_x = xm1 + (xc2 - xm1) * smooth_value + x1 - xm1;
        float ctrl1_y = ym1 + (yc2 - ym1) * smooth_value + y1 - ym1;

        float ctrl2_x = xm2 + (xc2 - xm2) * smooth_value + x2 - xm2;
        float ctrl2_y = ym2 + (yc2 - ym2) * smooth_value + y2 - ym2;

        if (isnan(ctrl1_x) || isnan(ctrl1_y)) {
            ctrl1_x = _point1.x;
            ctrl1_y = _point1.y;
        }

        if (isnan(ctrl2_x) || isnan(ctrl2_y)) {
            ctrl2_x = _point2.x;
            ctrl2_y = _point2.y;
        }

        ele = [MMCurveToPathElement elementWithStart:_point1
                                          andCurveTo:_point2
                                         andControl1:CGPointMake(ctrl1_x, ctrl1_y)
                                         andControl2:CGPointMake(ctrl2_x, ctrl2_y)];
    } else if (_point2.x == -CGFLOAT_MAX) {
        ele = [MMMoveToPathElement elementWithMoveTo:_point3];
    }

    return ele;
}


- (void)copyStateFrom:(MMSegmentSmoother *)otherSmoother
{
    _point0 = otherSmoother.point0;
    _point1 = otherSmoother.point1;
    _point2 = otherSmoother.point2;
    _point3 = otherSmoother.point3;
}

#pragma mark - Scale

- (void)scaleForWidth:(CGFloat)widthRatio andHeight:(CGFloat)heightRatio
{
    _point0.x = _point0.x * widthRatio;
    _point0.y = _point0.y * heightRatio;
    _point1.x = _point1.x * widthRatio;
    _point1.y = _point1.y * heightRatio;
    _point2.x = _point2.x * widthRatio;
    _point2.y = _point2.y * heightRatio;
    _point3.x = _point3.x * widthRatio;
    _point3.y = _point3.y * heightRatio;
}

#pragma mark - NSCopying

- (id)copyWithZone:(nullable NSZone *)zone
{
    MMSegmentSmoother *ret = [[MMSegmentSmoother alloc] init];

    ret->_point0 = _point0;
    ret->_point1 = _point1;
    ret->_point2 = _point2;
    ret->_point3 = _point3;

    return ret;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        _point0 = [coder decodeCGPointForKey:@"point0"];
        _point1 = [coder decodeCGPointForKey:@"point1"];
        _point2 = [coder decodeCGPointForKey:@"point2"];
        _point3 = [coder decodeCGPointForKey:@"point3"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeCGPoint:_point0 forKey:@"point0"];
    [coder encodeCGPoint:_point1 forKey:@"point1"];
    [coder encodeCGPoint:_point2 forKey:@"point2"];
    [coder encodeCGPoint:_point3 forKey:@"point3"];
}

@end
