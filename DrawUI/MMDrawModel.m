//
//  MMDrawModel.m
//  DrawUI
//
//  Created by Adam Wulf on 11/12/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "MMDrawModel.h"
#import "MMAbstractBezierPathElement.h"
#import "MMAbstractBezierPathElement-Protected.h"
#import "MMTouchStream.h"


@implementation MMDrawModel {
    MMTouchStreamEvent *_lastSeenEvent;
    NSUInteger _version;
}

- (instancetype)init
{
    if (self = [super init]) {
        _version = 0;
        _strokes = [NSMutableArray array];
        _touchStream = [[MMTouchStream alloc] init];
    }
    return self;
}

- (void)processTouchStreamWithTool:(MMPen *)tool
{
    NSArray<MMTouchStreamEvent *> *eventsToProcess;

    // get an array of all the events we need to process this cycle
    if (_lastSeenEvent) {
        eventsToProcess = [[self touchStream] eventsSinceEvent:_lastSeenEvent];
    } else {
        eventsToProcess = [[self touchStream] eventsSinceEvent:nil];
    }

    // increment our version since we're processing new stuff
    _version += 1;

    // for each event, either add it to a stroke, or create a stroke for it
    for (MMTouchStreamEvent *event in eventsToProcess) {
        if ([event phase] == UITouchPhaseBegan) {
            if (!_activeStroke || [[_activeStroke event] isSameTouchAsEvent:event]) {
                if (![event isUpdate]) {
                    _activeStroke = [[MMDrawnStroke alloc] initWithTool:tool];
                }

                [_activeStroke setVersion:_version];
                [_activeStroke addEvent:event];
            }
        } else {
            MMDrawnStroke *strokeForEvent = _activeStroke;

            if (!strokeForEvent) {
                // if we don't have an in-progress stroke for this event,
                // then it might be an event to update a recently completed stroke
                for (MMDrawnStroke *stroke in [_strokes reverseObjectEnumerator]) {
                    if ([stroke waitingForEvent:event]) {
                        // we found a recently completed stroke that we can update
                        strokeForEvent = stroke;
                        break;
                    }
                }
            }

            if ([[strokeForEvent event] isSameTouchAsEvent:event]) {
                // update the stroke to our new version
                [strokeForEvent setVersion:_version];

                if ([event phase] == UITouchPhaseMoved) {
                    [strokeForEvent addEvent:event];
                } else if ([event phase] == UITouchPhaseEnded) {
                    [strokeForEvent addEvent:event];

                    if (strokeForEvent == _activeStroke) {
                        // strokeForEvent might not equal _stroke if we're updating
                        // a recently completed stroke.
                        if ([_activeStroke path]) {
                            // this stroke is complete, save it to our history
                            [_strokes addObject:_activeStroke];
                        }

                        _activeStroke = nil;
                    }
                } else if ([event phase] == UITouchPhaseCancelled) {
                    _activeStroke = nil;
                }
            }
        }
    }

    _lastSeenEvent = [eventsToProcess lastObject] ?: _lastSeenEvent;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        _version = [[coder decodeObjectOfClass:[NSNumber class] forKey:@"version"] unsignedIntegerValue];
        _strokes = [[coder decodeObjectOfClasses:[NSSet setWithArray:@[[NSArray class], [MMDrawnStroke class]]] forKey:@"strokes"] mutableCopy] ?: [NSMutableArray array];
        _touchStream = [[MMTouchStream alloc] init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:@(_version) forKey:@"version"];
    [coder encodeObject:_strokes forKey:@"strokes"];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
    MMDrawModel *ret = [[[self class] allocWithZone:zone] init];

    ret->_version = _version;
    ret->_activeStroke = [_activeStroke copy];
    ret->_strokes = [[NSMutableArray alloc] initWithArray:_strokes copyItems:YES];

    return ret;
}

@end
