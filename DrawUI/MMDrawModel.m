//
//  MMDrawModel.m
//  DrawUI
//
//  Created by Adam Wulf on 11/12/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "MMDrawModel.h"
#import "MMDrawView.h"

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
                _strokeTouch = touch;
                _stroke = [[MMDrawnStroke alloc] initWithPen:[drawView tool]];

                [_stroke addTouch:touch inView:drawView];
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
                    [_stroke addTouch:coalescedTouch inView:drawView];
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
                    [_stroke addTouch:coalescedTouch inView:drawView];
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
