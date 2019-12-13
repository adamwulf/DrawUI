//
//  CAEraserLayer.m
//  DrawUI
//
//  Created by Adam Wulf on 11/30/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "CAEraserLayer.h"

@implementation CAEraserLayer {
    NSMutableDictionary<NSString *, UIBezierPath *> *_pathMap;
    NSMutableArray<NSString *> *_pathIds;
}

@synthesize fillColor;
@synthesize strokeColor;
@synthesize lineWidth;

- (void)setPath:(UIBezierPath *)path forIdentifier:(NSString *)identifier
{
    _pathMap = _pathMap ?: [NSMutableDictionary dictionary];
    _pathIds = _pathIds ?: [NSMutableArray array];

    if (![_pathIds containsObject:identifier]) {
        [_pathIds addObject:identifier];
    }

    [_pathMap setObject:path forKey:identifier];
    [self setNeedsDisplayInRect:[path bounds]];
}

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

    for (NSString *identifier in _pathIds) {
        CGContextAddPath(inContext, [[_pathMap objectForKey:identifier] CGPath]);
    }

    CGContextDrawPath(inContext, kCGPathFillStroke);
}

@end
