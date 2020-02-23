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
@property(nonatomic, strong) NSMutableArray<MMTouchStreamEvent *> *waitingEvents;

@end


@implementation MMDrawnStroke {
    MMSegmentSmoother *_savedSmoother;
}

@synthesize borderPath = _borderPath;

- (instancetype)initWithTool:(MMPen *)tool
{
    if (self = [super init]) {
        _identifier = [[NSUUID UUID] UUIDString];
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

- (UIBezierPath *)borderPath
{
    if (!_borderPath) {
        UIBezierPath *path = [UIBezierPath bezierPath];

        for (MMAbstractBezierPathElement *segment in [self segments]) {
            [path appendPath:[segment borderPath]];
        }

        _borderPath = path;
    }

    return _borderPath;
}

#pragma mark - Touches

- (MMTouchStreamEvent *)event
{
    return [[[[self segments] firstObject] events] firstObject];
}

- (BOOL)waitingForEvent:(MMTouchStreamEvent *)event
{
    return [event estimationUpdateIndex] && [_eventIdToSegment objectForKey:[event estimationUpdateIndex]];
}

/// Returns the element that was added or updated by this event
- (MMAbstractBezierPathElement *)addEvent:(MMTouchStreamEvent *)event;
{
    if ([event estimationUpdateIndex]) {
        // Check if we can update an existing element
        MMAbstractBezierPathElement *ele = [_eventIdToSegment objectForKey:[event estimationUpdateIndex]];

        if (ele) {
            // if we have an element for this event already, then update and return it
            CGFloat width = [_tool widthForEvent:event];

            [ele updateWithEvent:event width:width];
            [ele setVersion:[self version]];

            // we've updated our segments, clear out our border path
            _borderPath = nil;

            return ele;
        }
    }

    // otherwise, prepare to build a new element for this event if possible
    if ([event phase] == UITouchPhaseEnded || [event phase] == UITouchPhaseCancelled) {
        BOOL shortStrokeEnding = [_segments count] <= 1;

        [_tool willEndStrokeWithEvent:event shortStrokeEnding:shortStrokeEnding];
    } else if ([event phase] == UITouchPhaseBegan) {
        [_tool willBeginStrokeWithEvent:event];
    } else {
        [_tool willMoveStrokeWithEvent:event];
    }

    if ([event isPrediction]) {
        // if this is a prediction, then we need to save our smoother state
        // so that we can continue from where it left off once we get real data again
        _savedSmoother = _savedSmoother ?: [_smoother copy];
    } else {
        // now we have real non-prediction data, so remove all
        // elements that were built from predictions
        while ([[_segments lastObject] isPrediction]) {
            [_segments removeLastObject];
        }
        // and restore our smoother to our saved state pre-prediction
        _smoother = _savedSmoother ?: _smoother;
        _savedSmoother = nil;
    }

    // we know that this event may trigger a new element, and we have
    // either the current smoother or a prediction-only smoother ready
    // to build it for us.
    CGPoint point = [event location];
    CGFloat smoothness = [_tool smoothnessForEvent:event];
    CGFloat width = [_tool widthForEvent:event];
    MMAbstractBezierPathElement *ele = [_smoother addPoint:point andSmoothness:smoothness];

    // Now either finish initializing it with its width and previous segment, etc
    // we might not always get an element, that's up to the smoother to decide.
    // it might merge many events into a single element, and in that case
    // we should store the events that are being merged.
    if (ele) {
        NSArray<MMTouchStreamEvent *> *elementEvents = [_waitingEvents arrayByAddingObject:event];

        [_waitingEvents removeAllObjects];

        [ele setWidth:width];
        [ele setEvents:elementEvents];
        [ele setVersion:[self version]];

        if ([_segments count]) {
            [ele configurePreviousElement:[_segments lastObject]];
        }

        [_segments addObject:ele];

        // cache this element for each of its events. if any update ever comes in
        // for these event ids, then this segment should be updated with any new properties
        for (MMTouchStreamEvent *eleEvent in elementEvents) {
            if ([eleEvent estimationUpdateIndex]) {
                [_eventIdToSegment setObject:ele forKey:[eleEvent estimationUpdateIndex]];
            }
        }

        // we've added an element. we don't need to clear the whole path, we can
        // just update the element that exists
        [_borderPath appendPath:[ele borderPath]];

    } else {
        // we haven't generated enough events to build an element yet. This happens
        // as the smoother is determining the very first element
        [_waitingEvents addObject:event];
    }

    return ele;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        NSSet *allowedClasses = [NSSet setWithArray:@[[NSArray class], [NSDictionary class], [MMAbstractBezierPathElement class], [MMMoveToPathElement class], [MMCurveToPathElement class]]];

        _identifier = [coder decodeObjectOfClass:[NSString class] forKey:PROPERTYNAME(identifier)];
        _tool = [coder decodeObjectOfClass:[MMPen class] forKey:PROPERTYNAME(tool)];
        _segments = [[coder decodeObjectOfClasses:allowedClasses forKey:PROPERTYNAME(segments)] mutableCopy] ?: [NSMutableArray array];
        _smoother = [coder decodeObjectOfClass:[MMSegmentSmoother class] forKey:PROPERTYNAME(smoother)];
        _version = [[coder decodeObjectOfClass:[NSNumber class] forKey:PROPERTYNAME(version)] unsignedIntegerValue];
        _eventIdToSegment = [[coder decodeObjectOfClasses:allowedClasses forKey:PROPERTYNAME(eventIdToSegment)] mutableCopy] ?: [NSMutableDictionary dictionary];
        _waitingEvents = [[coder decodeObjectOfClasses:allowedClasses forKey:PROPERTYNAME(waitingEvents)] mutableCopy] ?: [NSMutableArray array];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[self identifier] forKey:PROPERTYNAME(identifier)];
    [coder encodeObject:[self tool] forKey:PROPERTYNAME(tool)];
    [coder encodeObject:[self segments] forKey:PROPERTYNAME(segments)];
    [coder encodeObject:[self smoother] forKey:PROPERTYNAME(smoother)];
    [coder encodeObject:@([self version]) forKey:PROPERTYNAME(version)];
    [coder encodeObject:_eventIdToSegment forKey:PROPERTYNAME(eventIdToSegment)];
    [coder encodeObject:_waitingEvents forKey:PROPERTYNAME(waitingEvents)];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    MMDrawnStroke *ret = [[[self class] allocWithZone:zone] initWithTool:[self tool]];

    ret->_version = _version;
    ret->_smoother = _smoother;
    ret->_identifier = _identifier;
    ret->_segments = [[NSMutableArray alloc] initWithArray:_segments copyItems:YES];
    ret->_waitingEvents = [[NSMutableArray alloc] initWithArray:_waitingEvents copyItems:YES];

    for (NSInteger idx = 1; idx < [ret->_segments count]; idx++) {
        // setup previous/next element relationships
        [ret->_segments[idx] configurePreviousElement:ret->_segments[idx - 1]];
    }

    ret->_borderPath = _borderPath;

    return ret;
}

@end
