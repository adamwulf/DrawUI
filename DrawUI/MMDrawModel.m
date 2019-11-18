//
//  MMDrawModel.m
//  DrawUI
//
//  Created by Adam Wulf on 11/12/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "MMDrawModel.h"
#import "MMDrawView.h"
#import "MMAbstractBezierPathElement.h"
#import "MMAbstractBezierPathElement-Protected.h"
#import "MMTouchStream.h"

@implementation MMDrawModel {
    MMTouchStreamEvent *_lastSeenEvent;
    NSObject *_strokeTouch;
}

- (instancetype)init
{
    if (self = [super init]) {
        _strokes = [NSMutableArray array];
    }
    return self;
}

- (void)processTouchStream:(MMTouchStream *)touchStream withTool:(MMPen *)tool
{
    NSArray<MMTouchStreamEvent *> *eventsToProcess;

    if (_lastSeenEvent) {
        eventsToProcess = [touchStream eventsSinceEvent:_lastSeenEvent matchingTouch:_strokeTouch != nil];
    } else {
        eventsToProcess = [touchStream eventsSinceEvent:nil];
    }

    for (MMTouchStreamEvent *event in eventsToProcess) {
        if ([event phase] == UITouchPhaseBegan) {
            if (!_strokeTouch || _strokeTouch == [event touch]) {
                _strokeTouch = [event touch];
                _stroke = [[MMDrawnStroke alloc] initWithTool:tool];

                [_stroke addEvent:event];
            }
        } else if ([event phase] == UITouchPhaseMoved) {
            if (_strokeTouch == [event touch]) {
                [_stroke addEvent:event];
            }
        } else if ([event phase] == UITouchPhaseEnded) {
            if (_strokeTouch == [event touch]) {
                [_stroke addEvent:event];

                if ([_stroke path]) {
                    // this stroke is complete, save it to our history
                    [_strokes addObject:_stroke];
                }

                _stroke = nil;
                _strokeTouch = nil;
            }
        } else if ([event phase] == UITouchPhaseCancelled) {
            if (_strokeTouch == [event touch]) {
                _strokeTouch = nil;
                _stroke = nil;
            }
        }
    }

    _lastSeenEvent = [eventsToProcess lastObject] ?: _lastSeenEvent;
}

@end
