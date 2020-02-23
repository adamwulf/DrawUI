//
//  CALayerRenderer.m
//  DrawUI
//
//  Created by Adam Wulf on 11/12/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "CALayerRenderer.h"
#import "MMAbstractBezierPathElement.h"
#import "CARealtimeEraserLayer.h"
#import "CACachedEraserLayer.h"
#import "CAPencilLayer.h"
#import "MMDrawnStroke.h"
#import "MMDrawModel.h"

#define kUseCachedEraserLayer 1


@interface CALayerRenderer () <CALayerDelegate>

@property(nonatomic, strong) UIView *canvasView;

@end


@implementation CALayerRenderer {
    NSMutableDictionary<NSString *, CALayer *> *_strokeLayers;
    NSUInteger _lastRenderedVersion;
    CALayer *_canvasLayer;
}

@synthesize dynamicWidth = _dynamicWidth;
@synthesize useCachedEraserLayerType = _useCachedEraserLayerType;

- (instancetype)initWithView:(UIView *)canvasView
{
    if (self = [super init]) {
        _useCachedEraserLayerType = YES;
        _canvasView = canvasView;
        [self reinitializeLayer];
    }
    return self;
}

- (void)reinitializeLayer
{
    // reload all of the layers
    [_canvasLayer removeFromSuperlayer];
    _canvasLayer = nil;

    _strokeLayers = [NSMutableDictionary dictionary];
    _lastRenderedVersion = 0;
    _canvasLayer = [CAPencilLayer layer];
    [_canvasLayer setDelegate:self];

    [[_canvasView layer] addSublayer:_canvasLayer];
    [[_canvasView layer] setActions:@{ @"sublayers": [NSNull null] }];
}

- (void)setDrawModel:(MMDrawModel *)drawModel
{
    [self reinitializeLayer];

    _drawModel = drawModel;

    [self renderModel:drawModel];
}

#pragma mark - Cache

- (__kindof CALayer *)layerForStroke:(NSString *)strokeId isEraser:(BOOL)eraser
{
    CALayer *layer = [_strokeLayers objectForKey:strokeId];

    if (!layer) {
        if ([self dynamicWidth]) {
            layer = [CALayer layer];
        } else {
            layer = [CAShapeLayer layer];
        }

        layer.delegate = self;

        [_strokeLayers setObject:layer forKey:strokeId];
    }

    return layer;
}

- (void)embedPencilLayerIfNecessary
{
    if ([_canvasLayer mask]) {
        // embed the canvas in a new pencil layer
        // so that this pencil line will be drawn
        // /over/ the eraser lines
        CALayer *subCanvasLayer = _canvasLayer;
        _canvasLayer = [CAPencilLayer layer];
        [_canvasLayer setFrame:[subCanvasLayer frame]];
        [subCanvasLayer setFrame:[subCanvasLayer bounds]];

        [[subCanvasLayer superlayer] addSublayer:_canvasLayer];
        [_canvasLayer addSublayer:subCanvasLayer];
    }
}

#pragma mark - Render

- (void)renderStroke:(MMDrawnStroke *)stroke
{
    if ([self dynamicWidth]) {
        if (![[stroke tool] color]) {
            // multiple eraser strokes in a row can all share the same CACachedEraserLayer
            // without any ill effect. Pencil layers need to maintain a correct ordering
            // of strokes, but for eraser strokes, order doesn't matter, so if we render
            // an updated finished stroke after the active stroke, there's no harm here
            CAEraserLayer *eraserLayer = [_canvasLayer mask];

            if (!eraserLayer) {
                if (_useCachedEraserLayerType) {
                    eraserLayer = [[CACachedEraserLayer alloc] initWithBounds:[[self canvasView] bounds]];
                } else {
                    eraserLayer = [[CARealtimeEraserLayer alloc] initWithBounds:[[self canvasView] bounds]];
                }

                [eraserLayer setOpaque:NO];
                [eraserLayer setFillColor:[UIColor colorWithWhite:0 alpha:0]];
                [eraserLayer setLineWidth:0];
                [_canvasLayer setMask:eraserLayer];
            }

            [eraserLayer setFrame:[[self canvasView] bounds]];

            for (MMAbstractBezierPathElement *ele in [stroke segments]) {
                // Only draw the element if:
                // 1. we're using realtime eraser (which will update predicted strokes)
                // 2. or the element is not a prediction (since the cached eraser can't remove previous path)
                if ([ele version] > [eraserLayer version] && (!_useCachedEraserLayerType || ![ele isPrediction])) {
                    // add the element's path to the eraser layer.
                    [eraserLayer setPath:[ele borderPath] forIdentifier:[ele identifier]];
                }
            }

            [eraserLayer setVersion:[stroke version]];
        } else {
            [self embedPencilLayerIfNecessary];

            // get the cached layer for this stroke. this stroke layer will contain
            // all the shape layers for each of its elements
            CALayer *layer = [self layerForStroke:[stroke identifier] isEraser:[[stroke tool] color] == nil];

            for (NSInteger i = 0; i < [[stroke segments] count]; i++) {
                MMAbstractBezierPathElement *element = [[stroke segments] objectAtIndex:i];
                CAShapeLayer *segmentLayer = i < [[layer sublayers] count] ? [[layer sublayers] objectAtIndex:i] : nil;

                if (!segmentLayer) {
                    // we don't have a layer for this segment yet, so build one
                    segmentLayer = [CAShapeLayer layer];
                    segmentLayer.delegate = self;
                    segmentLayer.fillColor = [[[stroke tool] color] CGColor] ?: [[UIColor blackColor] CGColor];
                    segmentLayer.lineWidth = 0;
                    [layer addSublayer:segmentLayer];
                }

                // update the path for this segment
                segmentLayer.path = [[element borderPath] CGPath];
            }

            if (!layer.superlayer) {
                // if we haven't added this stroke to our canvas yet, then add it.
                // we can't always call this, as it might re-order strokes or move
                // them to the wrong canvas, as updates for already drawn strokes
                // may come in to the renderStroke:inView: method
                [_canvasLayer addSublayer:layer];
            }
        }
    } else if ([stroke path]) {
        if (![[stroke tool] color]) {
            // same as above, we don't use a per-stroke eraser layers since order doesn't matter
            CAEraserLayer *eraserLayer = [_canvasLayer mask];

            if (!eraserLayer) {
                if (_useCachedEraserLayerType) {
                    eraserLayer = [[CACachedEraserLayer alloc] initWithBounds:[[self canvasView] bounds]];
                } else {
                    eraserLayer = [[CARealtimeEraserLayer alloc] initWithBounds:[[self canvasView] bounds]];
                }

                [eraserLayer setOpaque:NO];
                [eraserLayer setStrokeColor:[UIColor colorWithWhite:0 alpha:0]];
                [eraserLayer setLineWidth:10];
                [_canvasLayer setMask:eraserLayer];
            }

            [eraserLayer setFrame:[[self canvasView] bounds]];
            [eraserLayer setPath:[stroke path] forIdentifier:[stroke identifier]];
        } else {
            [self embedPencilLayerIfNecessary];

            CAShapeLayer *layer = [self layerForStroke:[stroke identifier] isEraser:[[stroke tool] color] == nil];

            layer.path = [[stroke path] CGPath];
            layer.strokeColor = [[[stroke tool] color] CGColor] ?: [[UIColor colorWithWhite:0 alpha:0] CGColor];
            layer.fillColor = [[UIColor clearColor] CGColor];
            layer.lineWidth = 10;

            if (!layer.superlayer) {
                [_canvasLayer addSublayer:layer];
            }
        }
    }
}

- (void)renderModel:(MMDrawModel *)drawModel
{
    NSUInteger maxSoFar = _lastRenderedVersion;

    for (MMDrawnStroke *stroke in [drawModel strokes]) {
        if ([stroke version] > _lastRenderedVersion) {
            [self renderStroke:stroke];

            maxSoFar = MAX([stroke version], maxSoFar);
        }
    }

    if ([drawModel activeStroke]) {
        if ([[drawModel activeStroke] version] > _lastRenderedVersion) {
            [self renderStroke:[drawModel activeStroke]];

            maxSoFar = MAX([[drawModel activeStroke] version], maxSoFar);
        }
    }

    _lastRenderedVersion = maxSoFar;
}

#pragma mark - MMDrawViewRenderer

- (void)invalidate
{
    [_canvasLayer removeFromSuperlayer];
    _canvasLayer = nil;
    _drawModel = nil;
}

- (void)drawModelWillUpdate:(MMDrawModel *)oldModel
{
    if (CGRectEqualToRect([_canvasLayer frame], [[[self canvasView] layer] bounds])) {
        [_canvasLayer setFrame:[[[self canvasView] layer] bounds]];
    }
}

- (void)drawModelDidUpdate:(MMDrawModel *)drawModel
{
    [self renderModel:drawModel];
}

#pragma mark - CALayerDelegate

- (nullable id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
    return [NSNull null];
}


@end
