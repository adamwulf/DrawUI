//
//  CALayer+DrawUI.m
//  DrawUI
//
//  Created by Adam Wulf on 11/29/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "CALayer+DrawUI.h"
#import <objc/runtime.h>

static char ERASER_PROP;
static char ERASER_DEPTH_PROP;

@implementation CALayer (DrawUI)

- (BOOL)isEraser
{
    NSNumber *eraser = objc_getAssociatedObject(self, &ERASER_PROP);

    return [eraser boolValue];
}

- (void)setEraser:(BOOL)eraser
{
    objc_setAssociatedObject(self, &ERASER_PROP, @(eraser), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)eraserDepth
{
    NSNumber *eraser = objc_getAssociatedObject(self, &ERASER_DEPTH_PROP);

    return [eraser unsignedIntegerValue];
}

- (void)setEraserDepth:(NSUInteger)eraserDepth
{
    objc_setAssociatedObject(self, &ERASER_DEPTH_PROP, @(eraserDepth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
