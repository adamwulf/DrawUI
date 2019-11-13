//
//  MMDrawnStroke.m
//  infinite-draw
//
//  Created by Adam Wulf on 10/5/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "MMDrawnStroke.h"
#import "MMAbstractBezierPathElement.h"
#import "MMMoveToPathElement.h"
#import "MMCurveToPathElement.h"
#import "MMSegmentSmoother.h"
#import "Constants.h"

CGFloat const Smoothness = 0.75;


@interface MMDrawnStroke ()

@property(nonatomic, strong) NSMutableArray<MMAbstractBezierPathElement *> *segments;
@property(nonatomic, strong) MMSegmentSmoother *smoother;

@end


@implementation MMDrawnStroke

- (instancetype)initWithPen:(MMPen *)pen
{
    if (self = [super init]) {
        _segments = [NSMutableArray array];
        _smoother = [[MMSegmentSmoother alloc] init];
    }
    return self;
}

#pragma mark - Properties

- (UIBezierPath *)path
{
    if ([_segments count] < 2) {
        return nil;
    }

    UIBezierPath *path = [UIBezierPath bezierPath];

    [_segments enumerateObjectsUsingBlock:^(MMAbstractBezierPathElement *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([obj isKindOfClass:[MMMoveToPathElement class]]) {
            [path moveToPoint:[obj startPoint]];
        } else if ([obj isKindOfClass:[MMCurveToPathElement class]]) {
            MMCurveToPathElement *curve = (MMCurveToPathElement *)obj;
            [path addCurveToPoint:[obj endPoint] controlPoint1:[curve ctrl1] controlPoint2:[curve ctrl2]];
        }
    }];

    return path;
}

#pragma mark - Touches

- (void)addTouch:(UITouch *)touch inView:(UIView *)view
{
    CGPoint point = [touch preciseLocationInView:view];
    MMAbstractBezierPathElement *ele = [_smoother addPoint:point andSmoothness:Smoothness];

    if (ele) {
        [_segments addObject:ele];
    }
}

@end
