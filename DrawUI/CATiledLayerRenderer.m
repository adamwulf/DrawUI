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
#import "Constants.h"

@interface CATiledLayerRenderer () <CALayerDelegate>

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
    }
    return self;
}

#pragma mark - Notifications

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIView *)drawView change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context
{
    [_tiledLayer setFrame:[[drawView layer] bounds]];
}

#pragma mark - MMDrawViewRenderer

- (void)installIntoDrawView:(MMDrawView *)drawView
{
    [[drawView layer] addSublayer:_tiledLayer];
    [_tiledLayer setFrame:[[drawView layer] bounds]];

    _lastModel = [drawView drawModel];

    [drawView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
    [_tiledLayer setNeedsDisplay];
}

- (void)uninstallFromDrawView:(MMDrawView *)drawView
{
    [_tiledLayer removeFromSuperlayer];
    [drawView removeObserver:self forKeyPath:@"bounds"];
}

- (void)drawView:(MMDrawView *)drawView willReplaceModel:(MMDrawModel *)oldModel withModel:(MMDrawModel *)newModel
{
}
- (void)drawView:(MMDrawView *)drawView didReplaceModel:(MMDrawModel *)oldModel withModel:(MMDrawModel *)newModel
{
    _lastModel = newModel;

    [_tiledLayer setNeedsDisplay];
}

- (void)drawView:(MMDrawView *)drawView willUpdateModel:(MMDrawModel *)oldModel
{
}

- (void)drawView:(MMDrawView *)drawView didUpdateModel:(MMDrawModel *)drawModel
{
    _lastModel = drawModel;

    MMDrawnStroke *stroke = [drawModel stroke] ?: [[drawModel strokes] lastObject];

    if (stroke) {
        CGRect pathBounds = [[stroke path] bounds];

        pathBounds = CGRectInset(pathBounds, -kStrokeWidth, -kStrokeWidth);

        [_tiledLayer setNeedsDisplayInRect:pathBounds];
    }
}

#pragma mark - CALayerDelegate

- (void)renderStroke:(MMDrawnStroke *)stroke inContext:(CGContextRef)ctx
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGRect r = CGContextGetClipBoundingBox(ctx);
    CGAffineTransform transform = CGContextGetCTM(ctx);
    CGRect rect = CGRectApplyAffineTransform(r, CGAffineTransformInvert(transform));

    if ([[stroke tool] color]) {
        [[[stroke tool] color] set];
    } else {
        // eraser
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [[UIColor whiteColor] set];
    }

    if ([self dynamicWidth]) {
        for (MMAbstractBezierPathElement *element in [[stroke segments] copy]) {
            UIBezierPath *segment = [element borderPath];

            if (CGRectIntersectsRect(r, [segment bounds])) {
                [segment fill];
            }
        }
    } else {
        UIBezierPath *path = [stroke path];

        if (path) {
            [path setLineWidth:kStrokeWidth];

            [path stroke];
        }
    }

    CGContextSetBlendMode(context, kCGBlendModeNormal);
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    UIGraphicsPushContext(ctx);

    for (MMDrawnStroke *stroke in [[_lastModel strokes] copy]) {
        [self renderStroke:stroke inContext:ctx];
    }

    [self renderStroke:[_lastModel stroke] inContext:ctx];

    UIGraphicsPopContext();
}

@end
