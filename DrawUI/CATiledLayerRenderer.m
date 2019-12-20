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
    MMDrawModel *_lastModel;
    CATiledLayer *_tiledLayer;
}

@synthesize dynamicWidth;

#pragma mark - Initializer

- (instancetype)init
{
    if (self = [super init]) {
        _tiledLayer = [CANoFadeTiledLayer layer];
        [_tiledLayer setDelegate:self];

        _ctxRenderer = [[CGContextRenderer alloc] init];
    }
    return self;
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

- (void)installIntoDrawView:(MMDrawView *)drawView
{
    [[drawView layer] addSublayer:_tiledLayer];
    [_tiledLayer setFrame:[[drawView layer] bounds]];

    _lastModel = [drawView drawModel];

    [[self ctxRenderer] setModel:_lastModel];
    [drawView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
    [_tiledLayer setNeedsDisplay];
}

- (void)uninstallFromDrawView:(MMDrawView *)drawView
{
    [_tiledLayer removeFromSuperlayer];
    [drawView removeObserver:self forKeyPath:@"bounds"];
}

- (void)drawView:(MMDrawView *)drawView didUpdateBounds:(CGRect)bounds
{
    [_tiledLayer setFrame:[[drawView layer] bounds]];
}

- (void)drawView:(MMDrawView *)drawView didReplaceModel:(MMDrawModel *)oldModel withModel:(MMDrawModel *)newModel
{
    _lastModel = newModel;

    [[self ctxRenderer] setModel:_lastModel];
    [_tiledLayer setNeedsDisplay];
}

- (void)drawView:(MMDrawView *)drawView didUpdateModel:(MMDrawModel *)drawModel
{
    MMDrawnStroke *stroke = [drawModel stroke] ?: [[drawModel strokes] lastObject];

    if (stroke) {
        CGRect pathBounds = [[stroke path] bounds];

        pathBounds = CGRectInset(pathBounds, -kStrokeWidth, -kStrokeWidth);

        [[self ctxRenderer] setModel:[drawModel copy]];

        [_tiledLayer setNeedsDisplayInRect:pathBounds];
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
