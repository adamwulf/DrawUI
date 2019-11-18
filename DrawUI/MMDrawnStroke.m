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
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, MMAbstractBezierPathElement *> *eventIdToSegment;
@property(nonatomic, strong) MMSegmentSmoother *smoother;

@end


@implementation MMDrawnStroke {
    NSMutableArray *_waitingEvents;
}

- (instancetype)initWithTool:(MMPen *)tool
{
    if (self = [super init]) {
        _tool = tool;
        _segments = [NSMutableArray array];
        _smoother = [[MMSegmentSmoother alloc] init];
        _eventIdToSegment = [NSMutableDictionary dictionary];
        _waitingEvents = [NSMutableArray array];
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

- (BOOL)containsEvent:(MMTouchStreamEvent *)event
{
    return [event estimationUpdateIndex] && [_eventIdToSegment objectForKey:[event estimationUpdateIndex]];
}

/// Returns the element that was added or updated by this event
- (MMAbstractBezierPathElement *)addEvent:(MMTouchStreamEvent *)event;
{
    BOOL isUpdate = NO;
    MMAbstractBezierPathElement *ele;

    if ([event estimationUpdateIndex]) {
        ele = [_eventIdToSegment objectForKey:[event estimationUpdateIndex]];
        isUpdate = ele != nil;
    }

    if (!isUpdate) {
        if ([event phase] == UITouchPhaseEnded || [event phase] == UITouchPhaseCancelled) {
            BOOL shortStrokeEnding = [_segments count] <= 1;

            [_tool willEndStrokeWithEvent:event shortStrokeEnding:shortStrokeEnding];
        } else if ([event phase] == UITouchPhaseBegan) {
            [_tool willBeginStrokeWithEvent:event];
        } else {
            [_tool willMoveStrokeWithEvent:event];
        }
    }

    if (!ele) {
        // if we didn't have a cached event, try to build one
        CGPoint point = [event location];
        CGFloat smoothness = [_tool smoothnessForEvent:event];

        ele = [_smoother addPoint:point andSmoothness:smoothness];
    }

    // Now either update the element, or finish initializing it
    // with its width and previous segment, etc
    if (ele) {
        if (isUpdate) {
            // update a current element
            [ele updateWithEvent:event];
        } else {
            CGFloat width = [_tool widthForEvent:event];

            [ele setWidth:width];
            [ele setEvents:[_waitingEvents arrayByAddingObject:event]];

            [_waitingEvents removeAllObjects];

            if ([_segments count]) {
                [ele validateDataGivenPreviousElement:[_segments lastObject]];
            }

            [_segments addObject:ele];

            for (MMTouchStreamEvent *eleEvent in [ele events]) {
                if ([event estimationUpdateIndex]) {
                    [_eventIdToSegment setObject:ele forKey:[eleEvent estimationUpdateIndex]];
                }
            }
        }
    } else {
        [_waitingEvents addObject:event];
    }

    return ele;
}

@end
