//
//  DebugRenderer.m
//  DrawUI
//
//  Created by Adam Wulf on 11/13/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "DebugRenderer.h"
#import "MMAbstractBezierPathElement.h"
#import "MMDrawModel.h"
#import "MMDrawnStroke.h"


@interface DebugRenderer ()

@property(nonatomic, strong) UIView *canvasView;

@end


@implementation DebugRenderer

@synthesize dynamicWidth;

- (instancetype)initWithView:(UIView *)canvasView
{
    if (self = [super init]) {
        _canvasView = canvasView;

        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [[self canvasView] addSubview:self];
        [self setOpaque:NO];

        [[[self leadingAnchor] constraintEqualToAnchor:[canvasView leadingAnchor]] setActive:YES];
        [[[self trailingAnchor] constraintEqualToAnchor:[canvasView trailingAnchor]] setActive:YES];
        [[[self topAnchor] constraintEqualToAnchor:[canvasView topAnchor]] setActive:YES];
        [[[self bottomAnchor] constraintEqualToAnchor:[canvasView bottomAnchor]] setActive:YES];
    }
    return self;
}

- (void)setDrawModel:(MMDrawModel *)drawModel
{
    _drawModel = drawModel;

    [self setNeedsDisplay];
}

#pragma mark - MMDrawViewRenderer

- (void)uninstall
{
    [self removeFromSuperview];
    _drawModel = nil;
}

- (void)didUpdateBounds:(CGRect)bounds
{
    [self setNeedsDisplay];
}

- (void)drawModelDidUpdate:(MMDrawModel *)drawModel
{
    _drawModel = drawModel;

    [self setNeedsDisplay];
}

#pragma mark - Rendering

- (void)drawFilledStroke:(MMDrawnStroke *)stroke
{
    MMAbstractBezierPathElement *previousElement;
    for (MMAbstractBezierPathElement *element in [stroke segments]) {
        UIBezierPath *segment = [element borderPath];

        if ([element isUpdated]) {
            [[[UIColor redColor] colorWithAlphaComponent:.1] setFill];
        } else if ([element isPrediction]) {
            [[[UIColor blueColor] colorWithAlphaComponent:.1] setFill];
        } else {
            [[[UIColor blackColor] colorWithAlphaComponent:.1] setFill];
        }

        [segment fill];
        previousElement = element;
    }
}

- (void)drawRect:(CGRect)rect
{
    if ([self dynamicWidth]) {
        for (MMDrawnStroke *stroke in [[self drawModel] strokes]) {
            [self drawFilledStroke:stroke];
        }

        [self drawFilledStroke:[[self drawModel] activeStroke]];
    } else {
        [[UIColor blackColor] setStroke];

        for (MMDrawnStroke *stroke in [[self drawModel] strokes]) {
            UIBezierPath *path = [stroke path];
            [path setLineWidth:2];

            [path stroke];
        }

        UIBezierPath *path = [[[self drawModel] activeStroke] path];
        [path setLineWidth:2];

        [[UIColor blackColor] setStroke];
        [path stroke];
    }
}

@end
