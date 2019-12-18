//
//  CGContextRenderer.m
//  DrawUI
//
//  Created by Adam Wulf on 12/17/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "CGContextRenderer.h"
#import "MMAbstractBezierPathElement.h"
#import "Constants.h"

@implementation CGContextRenderer {
    NSUInteger _lastRenderedVersion;
}

- (void)setModel:(MMDrawModel *)model
{
    _model = model;
    _lastRenderedVersion = 0;
}

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);

    NSUInteger maxSoFar = _lastRenderedVersion;

    for (MMDrawnStroke *stroke in [[[self model] strokes] copy]) {
        if (!_drawByDiff || [stroke version] > _lastRenderedVersion) {
            [self renderStroke:stroke inRect:rect inContext:context];

            maxSoFar = MAX([stroke version], maxSoFar);
        }
    }

    if (!_drawByDiff || [[[self model] stroke] version] > _lastRenderedVersion) {
        [self renderStroke:[[self model] stroke] inRect:rect inContext:context];

        maxSoFar = MAX([[[self model] stroke] version], maxSoFar);
    }

    _lastRenderedVersion = maxSoFar;

    UIGraphicsPopContext();
}

- (void)renderStroke:(MMDrawnStroke *)stroke inRect:(CGRect)rect inContext:(CGContextRef)context
{
    if ([[stroke tool] color]) {
        [[[stroke tool] color] set];
    } else {
        // eraser
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [[UIColor whiteColor] set];
    }

    if ([self dynamicWidth]) {
        for (MMAbstractBezierPathElement *element in [[stroke segments] copy]) {
            CGFloat maxWidth = MAX(element.width, element.previousElement.width);

            if (CGRectIntersectsRect(CGRectInset([element bounds], -maxWidth, -maxWidth), rect)) {
                UIBezierPath *segment = [element borderPath];

                [segment fill];
            }
        }
    } else {
        UIBezierPath *path = [stroke path];
        CGRect pathBounds = [[stroke path] bounds];

        pathBounds = CGRectInset(pathBounds, -kStrokeWidth, -kStrokeWidth);

        if (path && CGRectIntersectsRect(pathBounds, rect)) {
            [path setLineWidth:kStrokeWidth];

            [path stroke];
        }
    }

    CGContextSetBlendMode(context, kCGBlendModeNormal);
}

@end
