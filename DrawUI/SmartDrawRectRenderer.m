//
//  SmartDrawRectRenderer.m
//  DrawUI
//
//  Created by Adam Wulf on 11/13/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "SmartDrawRectRenderer.h"
#import "MMAbstractBezierPathElement.h"
#import "Constants.h"

@interface SmartDrawRectRenderer ()

@property(nonatomic, strong) MMDrawModel *model;

@end

@implementation SmartDrawRectRenderer

@synthesize dynamicWidth;

- (instancetype)init
{
    if (self = [super init]) {
        [self setOpaque:NO];
    }
    return self;
}

- (void)installIntoDrawView:(MMDrawView *)drawView
{
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [drawView addSubview:self];

    _model = [drawView drawModel];

    [[[self leadingAnchor] constraintEqualToAnchor:[drawView leadingAnchor]] setActive:YES];
    [[[self trailingAnchor] constraintEqualToAnchor:[drawView trailingAnchor]] setActive:YES];
    [[[self topAnchor] constraintEqualToAnchor:[drawView topAnchor]] setActive:YES];
    [[[self bottomAnchor] constraintEqualToAnchor:[drawView bottomAnchor]] setActive:YES];
    [self setNeedsDisplay];
}

- (void)uninstallFromDrawView:(MMDrawView *)drawView
{
    _model = nil;
    [self removeFromSuperview];
}

- (void)drawView:(MMDrawView *)drawView willReplaceModel:(MMDrawModel *)oldModel withModel:(MMDrawModel *)newModel
{
}

- (void)drawView:(MMDrawView *)drawView didReplaceModel:(MMDrawModel *)oldModel withModel:(MMDrawModel *)newModel
{
    _model = newModel;

    [self setNeedsDisplay];
}

- (void)drawView:(MMDrawView *)drawView willUpdateModel:(MMDrawModel *)oldModel
{
}

- (void)drawView:(MMDrawView *)drawView didUpdateModel:(MMDrawModel *)drawModel
{
    _model = drawModel;

    MMDrawnStroke *stroke = [drawModel stroke] ?: [[drawModel strokes] lastObject];

    if (stroke) {
        CGRect pathBounds = [[stroke path] bounds];

        pathBounds = CGRectInset(pathBounds, -[[stroke tool] maxSize], -[[stroke tool] maxSize]);
        pathBounds = CGRectInset(pathBounds, -kStrokeWidth, -kStrokeWidth);

        [self setNeedsDisplayInRect:pathBounds];
    }
}

- (void)drawRect:(CGRect)rect
{
    for (MMDrawnStroke *stroke in [[self model] strokes]) {
        [self renderStroke:stroke inRect:rect];
    }

    [self renderStroke:[[self model] stroke] inRect:rect];
}

- (void)renderStroke:(MMDrawnStroke *)stroke inRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

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
