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

@implementation MMDrawModel{
    UITouch *_strokeTouch;
}

-(instancetype)init{
    if(self = [super init]){
        _strokes = [NSMutableArray array];
    }
    return self;
}


#pragma mark - Drawing
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inView:(MMDrawView*)drawView
{
    for (UITouch *touch in touches) {
        @autoreleasepool {
            if (!_strokeTouch || _strokeTouch == touch) {
                [[drawView tool] willBeginStrokeWithCoalescedTouch:touch fromTouch:touch inDrawView:drawView];
                CGFloat width = [[drawView tool] widthForCoalescedTouch:touch fromTouch:touch inDrawView:drawView];
                CGFloat smooth = [[drawView tool] smoothnessForCoalescedTouch:touch fromTouch:touch inDrawView:drawView];

                _strokeTouch = touch;
                _stroke = [[MMDrawnStroke alloc] init];

                [_stroke addTouch:touch inView:drawView smoothness:smooth width:width];
            }
        }
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inView:(MMDrawView*)drawView
{
    for (UITouch *touch in touches) {
        @autoreleasepool {
            if (_strokeTouch == touch) {
                NSArray<UITouch *> *coalesced = [event coalescedTouchesForTouch:touch];
                if (![coalesced count]) {
                    coalesced = @[touch];
                }

                for (UITouch *coalescedTouch in coalesced) {
                    [[drawView tool] willMoveStrokeWithCoalescedTouch:coalescedTouch fromTouch:touch inDrawView:drawView];
                    
                    CGFloat width = [[drawView tool] widthForCoalescedTouch:touch fromTouch:touch inDrawView:drawView];
                    CGFloat smooth = [[drawView tool] smoothnessForCoalescedTouch:touch fromTouch:touch inDrawView:drawView];

                    [_stroke addTouch:coalescedTouch inView:drawView smoothness:smooth width:width];
                }
            }
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inView:(MMDrawView*)drawView
{
    for (UITouch *touch in touches) {
        @autoreleasepool {
            if (_strokeTouch == touch) {
                NSArray<UITouch *> *coalesced = [event coalescedTouchesForTouch:touch];
                if (![coalesced count]) {
                    coalesced = @[touch];
                }

                for (UITouch *coalescedTouch in coalesced) {
                    BOOL shortStrokeEnding = [_stroke.segments count] <= 1;

                    [[drawView tool] willEndStrokeWithCoalescedTouch:coalescedTouch fromTouch:touch shortStrokeEnding:shortStrokeEnding inDrawView:drawView];
                    
                    CGFloat width = [[drawView tool] widthForCoalescedTouch:touch fromTouch:touch inDrawView:drawView];
                    CGFloat smooth = [[drawView tool] smoothnessForCoalescedTouch:touch fromTouch:touch inDrawView:drawView];

                    [_stroke addTouch:coalescedTouch inView:drawView smoothness:smooth width:width];
                }

                if ([_stroke path]) {
                    // this stroke is complete, save it to our history
                    [_strokes addObject:_stroke];
                }

                _stroke = nil;
                _strokeTouch = nil;
            }
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inView:(MMDrawView*)drawView
{
    for (UITouch *touch in touches) {
        @autoreleasepool {
            if (_strokeTouch == touch) {
                _strokeTouch = nil;
                _stroke = nil;
            }
        }
    }
}

@end
