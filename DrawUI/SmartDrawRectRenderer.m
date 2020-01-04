//
//  SmartDrawRectRenderer.m
//  DrawUI
//
//  Created by Adam Wulf on 11/13/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "SmartDrawRectRenderer.h"
#import "MMAbstractBezierPathElement.h"
#import "CGContextRenderer.h"
#import "Constants.h"

@interface SmartDrawRectRenderer ()

@property(nonatomic, strong) MMDrawModel *model;
@property(nonatomic, strong) CGContextRenderer *ctxRenderer;

@end

@implementation SmartDrawRectRenderer

@synthesize dynamicWidth;

- (instancetype)init
{
    if (self = [super init]) {
        [self setOpaque:NO];

        _ctxRenderer = [[CGContextRenderer alloc] init];
    }
    return self;
}

- (BOOL)dynamicWidth
{
    return [[self ctxRenderer] dynamicWidth];
}

- (void)setDynamicWidth:(BOOL)dynamicWidth
{
    [[self ctxRenderer] setDynamicWidth:dynamicWidth];
}

#pragma mark - MMDrawViewRenderer

- (void)installIntoDrawView:(MMDrawView *)drawView
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [drawView addSubview:self];

    _model = [drawView drawModel];

    [[self ctxRenderer] setModel:[self model]];

    [[[self leadingAnchor] constraintEqualToAnchor:[drawView leadingAnchor]] setActive:YES];
    [[[self trailingAnchor] constraintEqualToAnchor:[drawView trailingAnchor]] setActive:YES];
    [[[self topAnchor] constraintEqualToAnchor:[drawView topAnchor]] setActive:YES];
    [[[self bottomAnchor] constraintEqualToAnchor:[drawView bottomAnchor]] setActive:YES];
    [self setNeedsDisplay];
}

- (void)uninstallFromDrawView:(MMDrawView *)drawView
{
    _model = nil;

    [[self ctxRenderer] setModel:nil];
    [self removeFromSuperview];
}

- (void)drawView:(MMDrawView *)drawView didUpdateBounds:(CGRect)bounds
{
    [self setNeedsDisplay];
}

- (void)drawView:(MMDrawView *)drawView didReplaceModel:(MMDrawModel *)oldModel withModel:(MMDrawModel *)newModel
{
    _model = newModel;

    [[self ctxRenderer] setModel:[self model]];
    [self setNeedsDisplay];
}

- (void)drawView:(MMDrawView *)drawView didUpdateModel:(MMDrawModel *)drawModel
{
    MMDrawnStroke *stroke = [drawModel activeStroke] ?: [[drawModel strokes] lastObject];

    if (stroke) {
        CGRect pathBounds = [[stroke path] bounds];

        pathBounds = CGRectInset(pathBounds, -[[stroke tool] maxSize], -[[stroke tool] maxSize]);
        pathBounds = CGRectInset(pathBounds, -kStrokeWidth, -kStrokeWidth);

        [self setNeedsDisplayInRect:pathBounds];
    }
}

#pragma mark - Rendering

- (void)drawRect:(CGRect)rect
{
    [[self ctxRenderer] drawRect:rect inContext:UIGraphicsGetCurrentContext()];
}

@end
