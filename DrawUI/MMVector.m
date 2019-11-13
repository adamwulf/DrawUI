//
//  MMVector.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/11/13.
//  Copyright (c) 2013 Milestone Made, LLC. All rights reserved.
//

#import "MMVector.h"

// http://stackoverflow.com/questions/7854043/drawing-rectangle-between-two-points-with-arbitrary-width


@implementation MMVector

+ (MMVector *)vectorWithPoint:(CGPoint)p1 andPoint:(CGPoint)p2
{
    return [[MMVector alloc] initWithPoint:p1 andPoint:p2];
}

+ (MMVector *)vectorWithX:(CGFloat)x andY:(CGFloat)y
{
    return [[MMVector alloc] initWithX:x andY:y];
}

+ (MMVector *)vectorWithAngle:(CGFloat)angle
{
    return [[MMVector alloc] initWithX:cosf(angle) andY:sinf(angle)];
}

- (id)initWithPoint:(CGPoint)p1 andPoint:(CGPoint)p2
{
    if (self = [super init]) {
        _x = p2.x - p1.x;
        _y = p2.y - p1.y;
    }
    return self;
}

- (id)initWithX:(CGFloat)x andY:(CGFloat)y
{
    if (self = [super init]) {
        _x = x;
        _y = y;
    }
    return self;
}

- (CGFloat)angle
{
    CGFloat theta = atanf(_y / _x);
    BOOL isYNeg = _y < 0;
    BOOL isXNeg = _x < 0;

    // adjust the angle depending on which quadrant it's in
    if (isYNeg && isXNeg) {
        theta -= M_PI;
    } else if (!isYNeg && isXNeg) {
        theta += M_PI;
    }
    return theta;
}

- (MMVector *)normal
{
    // just divide our x and y by our length
    CGFloat length = sqrt(_x * _x + _y * _y);
    return [MMVector vectorWithX:(_x / length) andY:(_y / length)];
}

- (MMVector *)normalizedTo:(CGFloat)someLength
{
    return [MMVector vectorWithX:(_x / someLength) andY:(_y / someLength)];
}

- (MMVector *)perpendicular
{
    // perp just swaps the x and y
    return [MMVector vectorWithX:-_y andY:_x];
}

- (CGFloat)magnitude
{
    return sqrtf(self.x * self.x + self.y * self.y);
}

- (MMVector *)flip
{
    // perp just swaps the x and y
    return [MMVector vectorWithX:-_x andY:-_y];
}

- (CGPoint)pointFromPoint:(CGPoint)point distance:(CGFloat)distance
{
    return CGPointMake(point.x + _x * distance,
                       point.y + _y * distance);
}

- (MMVector *)averageWith:(MMVector *)vector
{
    return [MMVector vectorWithX:(_x + vector.x) / 2 andY:(_y + vector.y) / 2];
}

- (MMVector *)addVector:(MMVector *)vector
{
    return [MMVector vectorWithX:_x + vector.x andY:_y + vector.y];
}

- (MMVector *)rotateBy:(CGFloat)angle
{
    CGFloat xprime = _x * cosf(angle) - _y * sinf(angle);
    CGFloat yprime = _x * sinf(angle) + _y * cosf(angle);
    return [MMVector vectorWithX:xprime andY:yprime];
}

- (MMVector *)mirrorAround:(MMVector *)normal
{
    CGFloat dotprod = -_x * normal.x - _y * normal.y;
    CGFloat xprime = _x + 2 * normal.x * dotprod;
    CGFloat yprime = _y + 2 * normal.y * dotprod;
    return [MMVector vectorWithX:xprime andY:yprime];
}


- (CGPoint)mirrorPoint:(CGPoint)point aroundPoint:(CGPoint)startPoint
{
    CGFloat dx, dy, a, b;
    CGFloat x2, y2;

    dx = self.x;
    dy = self.y;

    CGFloat x0 = startPoint.x;
    CGFloat y0 = startPoint.y;

    a = (dx * dx - dy * dy) / (dx * dx + dy * dy);
    b = 2 * dx * dy / (dx * dx + dy * dy);

    x2 = a * (point.x - x0) + b * (point.y - y0) + x0;
    y2 = b * (point.x - x0) - a * (point.y - y0) + y0;

    return CGPointMake(x2, y2);
}

- (CGFloat)angleBetween:(MMVector *)otherVector
{
    // angle with +ve x-axis, in the range (−π, π]
    float thetaA = atan2(otherVector.x, otherVector.y);
    float thetaB = atan2(self.x, self.y);

    float thetaAB = thetaB - thetaA;

    // get in range (−π, π]
    while (thetaAB <= -M_PI)
        thetaAB += 2 * M_PI;

    while (thetaAB > M_PI)
        thetaAB -= 2 * M_PI;

    return thetaAB;

    //    CGFloat scaler = self.x * otherVector.x + self.y * otherVector.y;
    //    return acosf(scaler / (self.magnitude * otherVector.magnitude));
}

- (CGPoint)asCGPoint
{
    return CGPointMake(self.x, self.y);
}

- (NSString *)description
{
    return [@"[MMVector: " stringByAppendingFormat:@"%f %f]", self.x, self.y];
}

- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    if ([object isKindOfClass:[MMVector class]]) {
        return self.x == [(MMVector *)object x] && self.y == [(MMVector *)object y];
    }
    return NO;
}

@end
