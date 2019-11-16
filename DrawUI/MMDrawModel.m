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
    MMTouchStreamEvent *event;
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

    if (event) {
        eventsToProcess = [touchStream eventsSinceEvent:event matchingTouch:_strokeTouch != nil];
    } else {
        eventsToProcess = [touchStream eventsSinceEvent:nil];
    }

    for (MMTouchStreamEvent *event in eventsToProcess) {
        if (![event isUpdate] && ![event isPrediction]) {
            if ([event phase] == UITouchPhaseBegan) {
                if (!_strokeTouch || _strokeTouch == [event touch]) {
                    [tool willBeginStrokeWithEvent:event];
                    CGFloat width = [tool widthForEvent:event];
                    CGFloat smooth = [tool smoothnessForEvent:event];

                    _strokeTouch = [event touch];
                    _stroke = [[MMDrawnStroke alloc] init];

                    [_stroke addPoint:[event location] smoothness:smooth width:width];
                }
            } else if ([event phase] == UITouchPhaseMoved) {
                if (_strokeTouch == [event touch]) {
                    [tool willMoveStrokeWithEvent:event];

                    CGFloat width = [tool widthForEvent:event];
                    CGFloat smooth = [tool smoothnessForEvent:event];

                    [_stroke addPoint:[event location] smoothness:smooth width:width];
                }
            } else if ([event phase] == UITouchPhaseEnded) {
                if (_strokeTouch == [event touch]) {
                    BOOL shortStrokeEnding = [_stroke.segments count] <= 1;

                    [tool willEndStrokeWithEvent:event shortStrokeEnding:shortStrokeEnding];

                    CGFloat width = [tool widthForEvent:event];
                    CGFloat smooth = [tool smoothnessForEvent:event];

                    [_stroke addPoint:[event location] smoothness:smooth width:width];

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
    }

    event = [eventsToProcess lastObject] ?: event;
}

@end
