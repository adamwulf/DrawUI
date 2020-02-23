//
//  MMTouchStream.m
//  DrawUI
//
//  Created by Adam Wulf on 11/15/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "MMTouchStream.h"
#import "MMTouchStreamGestureRecognizer.h"


@implementation MMTouchStream {
    NSMutableArray<MMTouchStreamEvent *> *_events;
}

- (instancetype)init
{
    if (self = [super init]) {
        _events = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Events

- (void)addEvent:(MMTouchStreamEvent *)touchStreamEvent
{
    [_events addObject:touchStreamEvent];
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
