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

- (MMTouchStreamEvent *)addStreamEvent:(UITouch *)touch velocity:(CGFloat)velocity
{
    BOOL isUpdate = [touch estimationUpdateIndex] ? [_estimatedIndexes containsObject:[touch estimationUpdateIndex]] : NO;

    MMTouchStreamEvent *event = [MMTouchStreamEvent eventWithTouch:touch velocity:velocity isUpdate:isUpdate];

    [_events addObject:event];

    if ([touch estimationUpdateIndex]) {
        [_estimatedIndexes addObject:[touch estimationUpdateIndex]];
    }

    return event;
}

- (NSArray<MMTouchStreamEvent *> *)eventsSinceToken:(MMTouchStreamEvent *)event
{
    return [self eventsSinceToken:event matchingTouch:NO];
}

- (NSArray<MMTouchStreamEvent *> *)eventsSinceToken:(MMTouchStreamEvent *)event matchingTouch:(BOOL)matching
{
    if (!event) {
        return [_events copy];
    }

    NSInteger index = [_events indexOfObject:event];

    if (index < [_events count] - 1) {
        // there's at least one more event
        NSArray<MMTouchStreamEvent *> *output = [_events subarrayWithRange:NSMakeRange(index + 1, [_events count] - index - 1)];

        if (matching) {
            return [output filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id _Nullable evaluatedObject, NSDictionary<NSString *, id> *_Nullable bindings) {
                return [evaluatedObject touch] == [event touch];
            }]];
        } else {
            return output;
        }
    } else {
        return @[];
    }
}

@end
