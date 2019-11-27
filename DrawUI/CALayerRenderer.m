//
//  CALayerRenderer.m
//  DrawUI
//
//  Created by Adam Wulf on 11/12/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "CALayerRenderer.h"
#import "MMAbstractBezierPathElement.h"

@implementation CALayerRenderer

@synthesize dynamicWidth;

#pragma mark - Render

- (void)renderStroke:(MMDrawnStroke *)stroke inView:(MMDrawView *)drawView
{
    if ([self dynamicWidth]) {
        UIBezierPath *strokePath = [UIBezierPath bezierPath];

        for (MMAbstractBezierPathElement *element in [[stroke segments] copy]) {
            [strokePath appendPath:[element borderPath]];
        }

        CAShapeLayer *layer = [CAShapeLayer layer];

        layer.path = [strokePath CGPath];
        layer.fillColor = [[UIColor blackColor] CGColor];
        layer.lineWidth = 0;

        [[drawView layer] addSublayer:layer];
    } else if ([stroke path]) {
        CAShapeLayer *layer = [CAShapeLayer layer];

        layer.path = [[stroke path] CGPath];
        layer.strokeColor = [[UIColor blackColor] CGColor];
        layer.fillColor = [[UIColor clearColor] CGColor];
        layer.lineWidth = 2;

        [[drawView layer] addSublayer:layer];
    }
}

- (void)renderModel:(MMDrawModel *)drawModel inView:(MMDrawView *)drawView
{
    [[[drawView layer] sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];

    for (MMDrawnStroke *stroke in [drawModel strokes]) {
        [self renderStroke:stroke inView:drawView];
    }

    [self renderStroke:[drawModel stroke] inView:drawView];
}

#pragma mark - MMDrawViewRenderer

- (void)drawView:(MMDrawView *)drawView willUpdateModel:(MMDrawModel *)oldModel to:(MMDrawModel *)newModel
{
}

- (void)drawView:(MMDrawView *)drawView didUpdateModel:(MMDrawModel *)drawModel
{
    [self renderModel:drawModel inView:drawView];
}

@end
