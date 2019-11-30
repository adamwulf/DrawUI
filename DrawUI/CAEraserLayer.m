//
//  CAEraserLayer.m
//  DrawUI
//
//  Created by Adam Wulf on 11/30/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "CAEraserLayer.h"
#import "MMDrawnStroke.h"
#import "MMAbstractBezierPathElement.h"
#import "CALayer+DrawUI.h"
#import "MMMoveToPathElement.h"

@interface CAEraserLayer () <CALayerDelegate>

@end

@implementation CAEraserLayer

- (void)setupWithCanvas:(CALayer *)canvas andStroke:(MMDrawnStroke *)stroke
{
    _originalCanvas = canvas;

    NSLog(@"setup with stroke: %@", @([[stroke segments] count]));

    NSUInteger startingDepth = 0;

    if ([[self sublayers] count]) {
        canvas = [[self sublayers] firstObject];
        startingDepth = [canvas eraserDepth];
        [canvas removeFromSuperlayer];
    }

    NSLog(@" - starting depth: %@", @(startingDepth));

    for (NSUInteger idx = startingDepth; idx < [[stroke segments] count]; idx++) {
        MMAbstractBezierPathElement *element = [[stroke segments] objectAtIndex:idx];

        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(-1000, -1000, 10000, 10000)];

        [path appendPath:[[element borderPath] bezierPathByReversingPath]];

        CAShapeLayer *elementMask = [CAShapeLayer layer];
        elementMask.delegate = self;
        elementMask.path = [path CGPath];
        elementMask.fillColor = [[UIColor whiteColor] CGColor];
        elementMask.lineWidth = 0;

        CALayer *maskedElement = [CALayer layer];
        [maskedElement addSublayer:canvas];
        [maskedElement setMask:elementMask];
        [maskedElement setEraserDepth:idx + 1];

        canvas = maskedElement;

        NSLog(@" - added mask, new depth: %@", @([maskedElement eraserDepth]));
    }

    [self addSublayer:canvas];
}

#pragma mark - CALayerDelegate

- (nullable id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
    return [NSNull null];
}

@end
