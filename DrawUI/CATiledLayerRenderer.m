//
//  CATiledLayerRenderer.m
//  DrawUI
//
//  Created by Adam Wulf on 11/13/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "CATiledLayerRenderer.h"
#import "MMAbstractBezierPathElement.h"
#import "CANoFadeTiledLayer.h"
#import "CGContextRenderer.h"
#import "Constants.h"


@interface CATiledLayerRenderer () <CALayerDelegate>

@property(nonatomic, strong) CGContextRenderer *ctxRenderer;

@end


@implementation CATiledLayerRenderer {
    CATiledLayer *_tiledLayer;
    UIView *_canvasView;
}

@synthesize dynamicWidth = _dynamicWidth;
@synthesize drawModel = _drawModel;

#pragma mark - Initializer

- (instancetype)initWithView:(UIView *)canvasView
{
    if (self = [super init]) {
        _canvasView = canvasView;
        _tiledLayer = [CANoFadeTiledLayer layer];
        [_tiledLayer setDelegate:self];

        [[canvasView layer] addSublayer:_tiledLayer];
        [_tiledLayer setFrame:[[canvasView layer] bounds]];

        _ctxRenderer = [[CGContextRenderer alloc] init];
    }
    return self;
}

- (void)setDrawModel:(MMDrawModel *)drawModel
{
    _drawModel = drawModel;

    [[self ctxRenderer] setModel:_drawModel];
    [_tiledLayer setNeedsDisplay];
}

- (BOOL)dynamicWidth
{
    return [[self ctxRenderer] dynamicWidth];
}

- (void)setDynamicWidth:(BOOL)dynamicWidth
{
    [[self ctxRenderer] setDynamicWidth:dynamicWidth];
}

#pragma mark - MMDrawViewRenderer

- (void)invalidate
{
    _drawModel = nil;

    [_tiledLayer removeFromSuperlayer];
}

- (void)drawModelDidUpdate:(MMDrawModel *)drawModel withBounds:(CGRect)bounds
{
    MMDrawnStroke *stroke = [drawModel activeStroke] ?: [[drawModel strokes] lastObject];

    if (stroke) {
        CGRect pathBounds = [[stroke path] bounds];

        pathBounds = CGRectInset(pathBounds, -kStrokeWidth, -kStrokeWidth);

        [[self ctxRenderer] setModel:[drawModel copy]];

        [_tiledLayer setNeedsDisplayInRect:pathBounds];
    }

    if (!CGRectEqualToRect([_tiledLayer frame], bounds)) {
        [_tiledLayer setFrame:bounds];
    }
}

#pragma mark - CALayerDelegate

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    CGRect clipRect = CGContextGetClipBoundingBox(ctx);
    CGAffineTransform transform = CGContextGetCTM(ctx);
    CGRect rect = CGRectApplyAffineTransform(clipRect, CGAffineTransformInvert(transform));

    [[self ctxRenderer] drawRect:clipRect inContext:ctx];
}

@end
