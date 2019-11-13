//
//  MMInfiniteView.m
//  infinite-draw
//
//  Created by Adam Wulf on 10/4/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "MMInfiniteView.h"
#import "MMSegmentSmoother.h"
#import "MMAbstractBezierPathElement.h"
#import "MMMoveToPathElement.h"
#import "MMCurveToPathElement.h"
#import "MMDrawnStroke.h"


@implementation MMInfiniteView {
    MMPen *_pen;
    UITouch *_strokeTouch;
    MMDrawnStroke *_stroke;
    NSMutableArray<MMDrawnStroke *> *_strokes;

    UIBezierPath *_currentStrokePath;
    CAShapeLayer *_currentStrokeLayer;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    _pen = [[MMPen alloc] initWithMinSize:2 andMaxSize:6];
    _strokes = [NSMutableArray array];

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    [panGesture setMinimumNumberOfTouches:2];
    [panGesture setMinimumNumberOfTouches:2];

    [self addGestureRecognizer:panGesture];

    _currentStrokeLayer = [CAShapeLayer layer];

    [[self layer] addSublayer:_currentStrokeLayer];
}

#pragma mark - Gestures

- (void)panGesture:(UIPanGestureRecognizer *)panGesture
{
}

#pragma mark - Render

- (void)renderStroke:(MMDrawnStroke *)stroke
{
    if ([stroke path]) {
        CAShapeLayer *layer = [CAShapeLayer layer];

        layer.path = [[stroke path] CGPath];
        layer.strokeColor = [[UIColor blackColor] CGColor];
        layer.fillColor = [[UIColor clearColor] CGColor];
        layer.lineWidth = 2;

        [[self layer] addSublayer:layer];
    }
}

- (void)renderAllStrokes
{
    [[[self layer] sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];

    for (MMDrawnStroke *stroke in _strokes) {
        [self renderStroke:stroke];
    }

    [self renderStroke:_stroke];
}

#pragma mark - Drawing

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        @autoreleasepool {
            if (!_strokeTouch || _strokeTouch == touch) {
                _strokeTouch = touch;
                _stroke = [[MMDrawnStroke alloc] initWithPen:_pen];

                [_stroke addTouch:touch inView:self];
            }
        }
    }

    [self renderAllStrokes];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        @autoreleasepool {
            if (_strokeTouch == touch) {
                NSArray<UITouch *> *coalesced = [event coalescedTouchesForTouch:touch];
                if (![coalesced count]) {
                    coalesced = @[touch];
                }

                for (UITouch *coalescedTouch in coalesced) {
                    [_stroke addTouch:coalescedTouch inView:self];
                }
            }
        }
    }

    [self renderAllStrokes];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        @autoreleasepool {
            if (_strokeTouch == touch) {
                NSArray<UITouch *> *coalesced = [event coalescedTouchesForTouch:touch];
                if (![coalesced count]) {
                    coalesced = @[touch];
                }

                for (UITouch *coalescedTouch in coalesced) {
                    [_stroke addTouch:coalescedTouch inView:self];
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

    [self renderAllStrokes];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        @autoreleasepool {
            if (_strokeTouch == touch) {
                _strokeTouch = nil;
                _stroke = nil;
            }
        }
    }

    [self renderAllStrokes];
}


@end
