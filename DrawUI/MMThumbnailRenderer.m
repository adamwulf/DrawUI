//
//  MMThumbnailRenderer.m
//  DrawUI
//
//  Created by Adam Wulf on 12/17/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "MMThumbnailRenderer.h"
#import "CGContextRenderer.h"

@interface MMThumbnailRenderer ()

@property(nonatomic, strong) CGContextRenderer *ctxRenderer;
@property(nonatomic, assign) CGContextRef imageContext;
@property(nonatomic, assign) CGColorSpaceRef colorSpace;
@end

@implementation MMThumbnailRenderer

@synthesize dynamicWidth;

- (instancetype)init
{
    if (self = [super init]) {
        _ctxRenderer = [[CGContextRenderer alloc] init];
        [_ctxRenderer setDrawByDiff:YES];
    }
    return self;
}

#pragma mark - MMDrawViewRenderer

- (void)uninstallFromDrawView:(MMDrawView *)drawView
{
    CGContextRelease(_imageContext);
    CGColorSpaceRelease(_colorSpace);
    _imageContext = nil;
}

- (void)installIntoDrawView:(MMDrawView *)drawView
{
    // gradient is always black-white and the mask must be in the gray colorspace
    _colorSpace = CGColorSpaceCreateDeviceRGB();

    // create the bitmap context

    _imageContext = CGBitmapContextCreate(NULL, 400, 400, 8, 0, _colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);

    [_ctxRenderer setModel:[drawView drawModel]];
}

- (void)drawView:(MMDrawView *)drawView didReplaceModel:(MMDrawModel *)oldModel withModel:(MMDrawModel *)newModel
{
    [_ctxRenderer setModel:newModel];
}

- (void)drawView:(MMDrawView *)drawView didUpdateModel:(MMDrawModel *)drawModel
{
    if ([[drawModel strokes] count] && ![drawModel activeStroke]) {
        [_ctxRenderer drawRect:[drawView bounds] inContext:_imageContext];

        CGImageRef theCGImage = CGBitmapContextCreateImage(_imageContext);

        UIImage *img = [[UIImage alloc] initWithCGImage:theCGImage];

        [UIImagePNGRepresentation(img) writeToFile:[NSString stringWithFormat:@"/Users/adamwulf/Downloads/%@.png", @(random())] atomically:YES];
    }
}

@end
