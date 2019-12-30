//
//  MMTouchStream.m
//  DrawUI
//
//  Created by Adam Wulf on 11/15/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "MMTouchStream.h"

@implementation MMTouchStream {
    NSMutableSet *_estimatedIndexes;
    NSMutableArray<MMTouchStreamEvent *> *_events;
}

- (instancetype)init
{
    if (self = [super init]) {
        _estimatedIndexes = [NSMutableSet set];
        _events = [NSMutableArray array];
    }
    return self;
}

- (MMTouchStreamEvent *)addStreamCoalescedTouch:(UITouch *)coalescedTouch touch:(UITouch *)touch velocity:(CGFloat)velocity isUpdate:(BOOL)isUpdate isPrediction:(BOOL)prediction
{
    MMTouchStreamEvent *event = [MMTouchStreamEvent eventWithCoalescedTouch:coalescedTouch touch:touch velocity:velocity isUpdate:isUpdate isPrediction:prediction];

    [_events addObject:event];

    if ([touch estimationUpdateIndex]) {
        [_estimatedIndexes addObject:[touch estimationUpdateIndex]];
    }

    return event;
}

- (NSArray<MMTouchStreamEvent *> *)eventsSinceEvent:(MMTouchStreamEvent *)event
{
    if (!event) {
        return [_events copy];
    }

    NSInteger index = [_events indexOfObject:event];

    if (index < [_events count] - 1) {
        // there's at least one more event
        return [_events subarrayWithRange:NSMakeRange(index + 1, [_events count] - index - 1)];
    } else if (index == NSNotFound) {
        return [_events copy];
    } else {
        return @[];
    }
}

@end
