//
//  DebugRenderer.m
//  DrawUI
//
//  Created by Adam Wulf on 11/13/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "DebugRenderer.h"
#import "MMAbstractBezierPathElement.h"

@interface DebugRenderer ()

@property(nonatomic, strong) MMDrawModel *model;

@end

@implementation DebugRenderer

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
        for (MMDrawnStroke *stroke in [[self model] strokes]) {
            [self drawFilledStroke:stroke];
        }

        [self drawFilledStroke:[[self model] stroke]];
    } else {
        [[UIColor blackColor] setStroke];

        for (MMDrawnStroke *stroke in [[self model] strokes]) {
            UIBezierPath *path = [stroke path];
            [path setLineWidth:2];

            [path stroke];
        }

        UIBezierPath *path = [[[self model] stroke] path];
        [path setLineWidth:2];

        [[UIColor blackColor] setStroke];
        [path stroke];
    }
}

@end
