//
//  CAEraserLayer2.m
//  DrawUI
//
//  Created by Adam Wulf on 12/18/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "CAEraserLayer2.h"

@implementation CAEraserLayer2 {
    NSMutableDictionary<NSString *, UIBezierPath *> *_pathMap;
    CGColorSpaceRef _colorSpace;
    CGContextRef _imageContext;
}

@synthesize fillColor;
@synthesize strokeColor;
@synthesize lineWidth;

- (instancetype)initWithBounds:(CGRect)bounds
{
    if (self = [super init]) {
        [self setBounds:bounds];

        _colorSpace = CGColorSpaceCreateDeviceRGB();
        _imageContext = CGBitmapContextCreate(NULL, CGRectGetWidth(bounds), CGRectGetHeight(bounds), 8, 0, _colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);

        UIGraphicsPushContext(_imageContext);

        // flip the context
        CGContextTranslateCTM(_imageContext, 0, CGRectGetHeight(bounds));
        CGContextScaleCTM(_imageContext, 1, -1);

        // set background to black
        CGContextSetGrayFillColor(_imageContext, 0.0, 1.0);
        CGContextFillRect(_imageContext, [self bounds]);
        UIGraphicsPopContext();
    }
    return self;
}

- (void)dealloc
{
    CGImageRef previousContent = (__bridge CGImageRef)([self contents]);

    if (previousContent) {
        [self setContents:nil];
        // release previous image
        CGImageRelease(previousContent);
    }

    CGContextRelease(_imageContext);
    CGColorSpaceRelease(_colorSpace);
}

- (void)setPath:(UIBezierPath *)path forIdentifier:(NSString *)identifier
{
    [_pathMap setObject:path forKey:identifier];

    UIGraphicsPushContext(_imageContext);
    CGContextSetBlendMode(_imageContext, kCGBlendModeSourceIn);

    if (self.strokeColor) {
        CGContextSetLineWidth(_imageContext, self.lineWidth);
        CGContextSetStrokeColorWithColor(_imageContext, [self.strokeColor CGColor]);
    }
    if (self.fillColor) {
        CGContextSetFillColorWithColor(_imageContext, [self.fillColor CGColor]);
    }

    CGContextBeginPath(_imageContext);
    CGContextAddPath(_imageContext, [path CGPath]);

    if (self.strokeColor) {
        CGContextStrokePath(_imageContext);
    }
    if (self.fillColor) {
        CGContextFillPath(_imageContext);
    }

    CGContextSetBlendMode(_imageContext, kCGBlendModeNormal);

    CGImageRef output = CGBitmapContextCreateImage(_imageContext);

    CGImageRef previousContent = (__bridge CGImageRef)([self contents]);

    [self setContents:(__bridge id)output];

    if (previousContent) {
        // release previous image
        CGImageRelease(previousContent);
    }

    UIGraphicsPopContext();
}

@end
