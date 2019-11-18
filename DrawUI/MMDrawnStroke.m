//
//  MMDrawnStroke.m
//  infinite-draw
//
//  Created by Adam Wulf on 10/5/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "MMDrawnStroke.h"
#import "MMAbstractBezierPathElement.h"
#import "MMAbstractBezierPathElement-Protected.h"
#import "MMMoveToPathElement.h"
#import "MMCurveToPathElement.h"
#import "MMSegmentSmoother.h"
#import "Constants.h"
#import "MMTouchStreamEvent.h"
#import "MMPen.h"

@interface MMDrawnStroke ()

@property(nonatomic, strong) NSMutableArray<MMAbstractBezierPathElement *> *segments;
@property(nonatomic, strong) MMSegmentSmoother *smoother;

@end


@implementation MMDrawnStroke {
    BOOL _firstEvent;
}

- (instancetype)initWithTool:(MMPen *)tool
{
    if (self = [super init]) {
        _tool = tool;
        _segments = [NSMutableArray array];
        _smoother = [[MMSegmentSmoother alloc] init];
        _firstEvent = YES;
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

- (MMAbstractBezierPathElement *)addEvent:(MMTouchStreamEvent *)event isEnding:(BOOL)ending;
{
    if (ending) {
        BOOL shortStrokeEnding = [_segments count] <= 1;

        [_tool willEndStrokeWithEvent:event shortStrokeEnding:shortStrokeEnding];
    } else if (_firstEvent) {
        [_tool willBeginStrokeWithEvent:event];
        _firstEvent = NO;
    } else {
        [_tool willMoveStrokeWithEvent:event];
    }

    CGPoint point = [event location];
    CGFloat smoothness = [_tool smoothnessForEvent:event];
    MMAbstractBezierPathElement *ele = [_smoother addPoint:point andSmoothness:smoothness];

    if (ele) {
        CGFloat width = [_tool widthForEvent:event];

        [ele setWidth:width];

        if ([_segments count]) {
            [ele validateDataGivenPreviousElement:[_segments lastObject]];
        }

        [_segments addObject:ele];
    }

    return ele;
}

@end
