//
//  MMSegmentSmoother.h
//  JotUI
//
//  Created by Adam Wulf on 12/19/12.
//  Copyright (c) 2012 Milestone Made. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MMPlistSaving.h"

@class MMAbstractBezierPathElement;


@interface MMSegmentSmoother : NSObject <MMPlistSaving>

@property(nonatomic, readonly) CGPoint point0;
@property(nonatomic, readonly) CGPoint point1;
@property(nonatomic, readonly) CGPoint point2;
@property(nonatomic, readonly) CGPoint point3;


/**
 * This method will add the point and try to interpolate a
 * curve/line/moveto segment from this new point and the points
 * that have come before.
 *
 * The first two points will generate the first moveto segment,
 * and subsequent points after that will generate curve
 * segments
 */
- (MMAbstractBezierPathElement *)addPoint:(CGPoint)inPoint andSmoothness:(CGFloat)smoothFactor;

- (void)copyStateFrom:(MMSegmentSmoother *)otherSmoother;

- (void)scaleForWidth:(CGFloat)widthRatio andHeight:(CGFloat)heightRatio;

@end
