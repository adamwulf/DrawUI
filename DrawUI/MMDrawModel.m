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
    NSUInteger _version;
}

- (instancetype)init
{
    if (self = [super init]) {
        _version = 0;
        _strokes = [NSMutableArray array];
    }
    return self;
}

- (void)processTouchStream:(MMTouchStream *)touchStream withTool:(MMPen *)tool
{
    NSArray<MMTouchStreamEvent *> *eventsToProcess;

    if (_lastSeenEvent) {
        eventsToProcess = [touchStream eventsSinceEvent:_lastSeenEvent matchingTouch:NO];
    } else {
        eventsToProcess = [touchStream eventsSinceEvent:nil];
    }

    _version += 1;

    [_stroke setVersion:_version];

    for (MMTouchStreamEvent *event in eventsToProcess) {
        if ([event phase] == UITouchPhaseBegan) {
            if (!_stroke || [_stroke touch] == [event touch]) {
                if (![event isUpdate]) {
                    _stroke = [[MMDrawnStroke alloc] initWithTool:tool];
                }

                [_stroke addEvent:event];
            }
        } else {
            MMDrawnStroke *strokeForEvent = _stroke;

            if (!strokeForEvent) {
                for (MMDrawnStroke *stroke in [_strokes reverseObjectEnumerator]) {
                    if ([stroke containsEvent:event]) {
                        strokeForEvent = stroke;
                        break;
                    }
                }
            }

            [strokeForEvent setVersion:_version];

            if ([event phase] == UITouchPhaseMoved) {
                if ([strokeForEvent touch] == [event touch]) {
                    [strokeForEvent addEvent:event];
                }
            } else if ([event phase] == UITouchPhaseEnded) {
                if ([strokeForEvent touch] == [event touch]) {
                    [strokeForEvent addEvent:event];

                    if (strokeForEvent == _stroke) {
                        if ([_stroke path]) {
                            // this stroke is complete, save it to our history
                            [_strokes addObject:_stroke];
                        }

                        _stroke = nil;
                    }
                }
            } else if ([event phase] == UITouchPhaseCancelled) {
                if ([strokeForEvent touch] == [event touch]) {
                    _stroke = nil;
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
    MMDrawModel *ret = [[MMDrawModel allocWithZone:zone] init];

    ret->_version = _version;
    ret->_stroke = [_stroke copy];
    ret->_strokes = [[NSMutableArray alloc] initWithArray:_strokes copyItems:YES];

    return ret;
}

@end
