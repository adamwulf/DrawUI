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

@implementation CGContextRenderer

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);

    for (MMDrawnStroke *stroke in [[self model] strokes]) {
        [self renderStroke:stroke inRect:rect inContext:context];
    }

    [self renderStroke:[[self model] stroke] inRect:rect inContext:context];

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
        for (MMAbstractBezierPathElement *element in [stroke segments]) {
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
