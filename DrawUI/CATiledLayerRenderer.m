//
//  CATiledLayerRenderer.m
//  DrawUI
//
//  Created by Adam Wulf on 11/13/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "CATiledLayerRenderer.h"
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
        _tiledLayer = [CATiledLayer layer];
        [_tiledLayer setDelegate:self];
    }
    return self;
}

#pragma mark - MMDrawViewRenderer

- (void)drawView:(MMDrawView *)drawView willUpdateModel:(MMDrawModel *)oldModel to:(MMDrawModel *)newModel
{
}

- (void)drawView:(MMDrawView *)drawView didUpdateModel:(MMDrawModel *)drawModel
{
    if (![_tiledLayer superlayer]) {
        [[drawView layer] addSublayer:_tiledLayer];
        [_tiledLayer setFrame:[[drawView layer] bounds]];
    }

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
    if ([stroke path]) {
        UIBezierPath *path = [[stroke path] copy];

        [path setLineWidth:2];
        [[UIColor blackColor] setStroke];

        [path stroke];
    }
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
