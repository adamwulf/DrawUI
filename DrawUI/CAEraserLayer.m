//
//  CAEraserLayer.m
//  DrawUI
//
//  Created by Adam Wulf on 11/30/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "CAEraserLayer.h"

@implementation CAEraserLayer

@synthesize path;
@synthesize fillColor;
@synthesize strokeColor;
@synthesize lineWidth;

- (void)drawInContext:(CGContextRef)inContext
{
    CGContextSetGrayFillColor(inContext, 0.0, 1.0);
    CGContextFillRect(inContext, self.bounds);
    CGContextSetBlendMode(inContext, kCGBlendModeSourceIn);
    if (self.strokeColor) {
        CGContextSetStrokeColorWithColor(inContext, [self.strokeColor CGColor]);
    }
    if (self.fillColor) {
        CGContextSetFillColorWithColor(inContext, [self.fillColor CGColor]);
    }
    CGContextSetLineWidth(inContext, self.lineWidth);
    CGContextAddPath(inContext, [self.path CGPath]);
    CGContextDrawPath(inContext, kCGPathFillStroke);
}

@end
