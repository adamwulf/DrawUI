//
//  NaiveDrawRectRenderer.m
//  DrawUI
//
//  Created by Adam Wulf on 11/13/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "NaiveDrawRectRenderer.h"
#import "MMAbstractBezierPathElement.h"

@interface NaiveDrawRectRenderer ()

@property(nonatomic, strong) MMDrawModel *model;

@end

@implementation NaiveDrawRectRenderer

@synthesize dynamicWidth;

- (instancetype)init
{
    if (self = [super init]) {
        [self setOpaque:NO];
    }
    return self;
}

- (void)drawView:(MMDrawView *)drawView willUpdateModel:(MMDrawModel *)oldModel to:(MMDrawModel *)newModel
{
    if ([self superview] != drawView) {
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [drawView addSubview:self];

        [[[self leadingAnchor] constraintEqualToAnchor:[drawView leadingAnchor]] setActive:YES];
        [[[self trailingAnchor] constraintEqualToAnchor:[drawView trailingAnchor]] setActive:YES];
        [[[self topAnchor] constraintEqualToAnchor:[drawView topAnchor]] setActive:YES];
        [[[self bottomAnchor] constraintEqualToAnchor:[drawView bottomAnchor]] setActive:YES];
    }
}

- (void)drawView:(MMDrawView *)drawView didUpdateModel:(MMDrawModel *)drawModel
{
    _model = drawModel;

    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if ([self dynamicWidth]) {
        for (MMDrawnStroke *stroke in [[self model] strokes]) {
            [[[stroke tool] color] setFill];

            for (MMAbstractBezierPathElement *element in [stroke segments]) {
                UIBezierPath *segment = [element borderPath];

                [segment fill];
            }
        }

        for (MMAbstractBezierPathElement *element in [[[self model] stroke] segments]) {
            UIBezierPath *segment = [element borderPath];

            [segment fill];
        }
    } else {
        for (MMDrawnStroke *stroke in [[self model] strokes]) {
            UIBezierPath *path = [stroke path];
            [path setLineWidth:2];

            [[[stroke tool] color] setStroke];
            [path stroke];
        }

        UIBezierPath *path = [[[self model] stroke] path];
        [path setLineWidth:2];

        [[[[[self model] stroke] tool] color] setStroke];
        [path stroke];
    }
}

@end
