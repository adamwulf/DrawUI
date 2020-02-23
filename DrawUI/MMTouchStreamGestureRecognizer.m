//
//  MMTouchStreamGestureRecognizer.m
//  DrawUI
//
//  Created by Adam Wulf on 2/23/20.
//  Copyright © 2020 Milestone Made. All rights reserved.
//

#import "MMTouchStreamGestureRecognizer.h"
#import "MMTouchVelocityGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>


@interface MMTouchStreamGestureRecognizer ()

@property(nonatomic, strong) NSMutableSet *activeTouches;

@end


@implementation MMTouchStreamGestureRecognizer

- (instancetype)initWithTouchStream:(MMTouchStream *)touchStream target:(nullable id)target action:(nullable SEL)action
{
    if (self = [super initWithTarget:target action:action]) {
        _touchStream = touchStream;
        _activeTouches = [NSMutableSet set];

        [self setDelaysTouchesBegan:NO];
        [self setDelaysTouchesEnded:NO];
        [self setAllowedTouchTypes:@[@(UITouchTypeDirect), @(UITouchTypeStylus)]];
    }
    return self;
}

#pragma mark - Touch Stream

- (void)processTouches:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event isUpdate:(BOOL)isUpdate
{
    for (UITouch *touch in touches) {
        NSArray<UITouch *> *coalesced = [event coalescedTouchesForTouch:touch];

        if (![coalesced count]) {
            coalesced = @[touch];
        }

        for (UITouch *coalescedTouch in coalesced) {
            CGFloat velocity = [[MMTouchVelocityGestureRecognizer sharedInstance] normalizedVelocityForTouch:touch];

            [_touchStream addEvent:[MMTouchStreamEvent eventWithCoalescedTouch:coalescedTouch touch:touch velocity:velocity isUpdate:isUpdate isPrediction:NO]];
        }

        NSArray<UITouch *> *predicted = [event predictedTouchesForTouch:touch];

        for (UITouch *predictedTouch in predicted) {
            CGFloat velocity = [[MMTouchVelocityGestureRecognizer sharedInstance] normalizedVelocityForTouch:touch];

            [_touchStream addEvent:[MMTouchStreamEvent eventWithCoalescedTouch:predictedTouch touch:touch velocity:velocity isUpdate:isUpdate isPrediction:YES]];
        }
    }
}

#pragma mark - Touch Events

- (void)touchesEstimatedPropertiesUpdated:(NSSet<UITouch *> *)touches
{
    [self processTouches:touches withEvent:nil isUpdate:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_activeTouches unionSet:touches];

    [super touchesBegan:touches withEvent:event];
    [self processTouches:touches withEvent:event isUpdate:NO];
    [self setState:UIGestureRecognizerStateBegan];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self processTouches:touches withEvent:event isUpdate:NO];
    [self setState:UIGestureRecognizerStateChanged];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_activeTouches minusSet:touches];

    [super touchesEnded:touches withEvent:event];
    [self processTouches:touches withEvent:event isUpdate:NO];

    if ([[self activeTouches] count]) {
        [self setState:UIGestureRecognizerStateChanged];
    } else {
        [self setState:UIGestureRecognizerStateEnded];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_activeTouches minusSet:touches];

    [self processTouches:touches withEvent:event isUpdate:NO];

    if ([[self activeTouches] count]) {
        [self setState:UIGestureRecognizerStateChanged];
    } else {
        [self setState:UIGestureRecognizerStateEnded];
    }
}

#pragma mark - UIGestureRecognizer Subclass

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    return NO;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    return NO;
}

- (BOOL)shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (BOOL)shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[%@ %p]", NSStringFromClass([self class]), self];
}

@end
