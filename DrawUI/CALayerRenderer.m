//
//  CALayerRenderer.m
//  DrawUI
//
//  Created by Adam Wulf on 11/12/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "CALayerRenderer.h"
#import "MMAbstractBezierPathElement.h"
#import "CALayer+DrawUI.h"
#import <CoreImage/CoreImage.h>
#import "CAEraserLayer.h"

@interface CALayerRenderer () <CALayerDelegate>

@end

@implementation CALayerRenderer {
    NSMutableDictionary<NSString *, CALayer *> *_strokeLayers;
    NSUInteger _lastRenderedVersion;
    CALayer *_canvasLayer;
}

@synthesize dynamicWidth;

- (instancetype)init
{
    if (self = [super init]) {
        _strokeLayers = [NSMutableDictionary dictionary];
        _lastRenderedVersion = 0;
        _canvasLayer = [CALayer layer];
        [_canvasLayer setDelegate:self];
    }
    return self;
}

#pragma mark - Render

- (__kindof CALayer *)layerForStroke:(NSString *)strokeId
{
    CALayer *layer = [_strokeLayers objectForKey:strokeId];

    if (!layer) {
        if ([self dynamicWidth]) {
            layer = [CAEraserLayer layer];
        } else {
            layer = [CAShapeLayer layer];
        }

        layer.delegate = self;

        [_strokeLayers setObject:layer forKey:strokeId];
    }

    return layer;
}

- (void)renderStroke:(MMDrawnStroke *)stroke inView:(MMDrawView *)drawView
{
    if (![[drawView layer] actions]) {
        [[drawView layer] setActions:@{ @"sublayers": [NSNull null] }];
    }
    if (![_canvasLayer superlayer]) {
        [[drawView layer] addSublayer:_canvasLayer];
    }

    if ([self dynamicWidth]) {
        CALayer *layer = [self layerForStroke:[stroke identifier]];

        if ([[stroke tool] color]) {
            for (NSInteger i = 0; i < [[stroke segments] count]; i++) {
                MMAbstractBezierPathElement *element = [[stroke segments] objectAtIndex:i];

                CAShapeLayer *segmentLayer = i < [[layer sublayers] count] ? [[layer sublayers] objectAtIndex:i] : [CAShapeLayer layer];

                segmentLayer.delegate = self;
                segmentLayer.path = [[element borderPath] CGPath];
                segmentLayer.fillColor = [[[stroke tool] color] CGColor] ?: [[UIColor whiteColor] CGColor];
                segmentLayer.lineWidth = 0;

                // regular pen
                if (![segmentLayer superlayer]) {
                    [layer addSublayer:segmentLayer];
                }
            }

            if (!layer.superlayer) {
                [_canvasLayer addSublayer:layer];
            }
        } else {
            CAEraserLayer *eraserLayer = (CAEraserLayer *)layer;

            [eraserLayer setEraser:YES];
            [eraserLayer setupWithCanvas:[eraserLayer originalCanvas] ?: _canvasLayer andStroke:stroke];

            _canvasLayer = eraserLayer;
        }
    } else if ([stroke path]) {
        CAShapeLayer *layer = [self layerForStroke:[stroke identifier]];

        layer.path = [[stroke path] CGPath];
        layer.strokeColor = [[[stroke tool] color] CGColor] ?: [[UIColor whiteColor] CGColor];
        layer.fillColor = [[UIColor clearColor] CGColor];
        layer.lineWidth = 10;

        if (![[stroke tool] color]) {
            [layer setEraser:YES];
        }

        if (!layer.superlayer) {
            [_canvasLayer addSublayer:layer];
        }
    }
}

- (void)renderModel:(MMDrawModel *)drawModel inView:(MMDrawView *)drawView
{
    NSUInteger maxSoFar = _lastRenderedVersion;

    for (MMDrawnStroke *stroke in [drawModel strokes]) {
        if ([stroke version] > _lastRenderedVersion) {
            [self renderStroke:stroke inView:drawView];

            maxSoFar = MAX([stroke version], maxSoFar);
        }
    }

    if ([drawModel stroke]) {
        if ([[drawModel stroke] version] > _lastRenderedVersion) {
            [self renderStroke:[drawModel stroke] inView:drawView];

            maxSoFar = MAX([[drawModel stroke] version], maxSoFar);
        }
    }

    _lastRenderedVersion = maxSoFar;
}

#pragma mark - CALayerDelegate

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    if ([layer isEraser]) {
        CGContextSetBlendMode(context, kCGBlendModeClear);
    }

    [layer renderInContext:context];

    CGContextSetBlendMode(context, kCGBlendModeNormal);
}

#pragma mark - MMDrawViewRenderer

- (void)drawView:(MMDrawView *)drawView willUpdateModel:(MMDrawModel *)oldModel to:(MMDrawModel *)newModel
{
}

- (void)drawView:(MMDrawView *)drawView didUpdateModel:(MMDrawModel *)drawModel
{
    [self renderModel:drawModel inView:drawView];
}

#pragma mark - CALayerDelegate

- (nullable id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
    return [NSNull null];
}


@end
