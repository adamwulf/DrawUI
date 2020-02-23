//
//  NaiveDrawRectRenderer.m
//  DrawUI
//
//  Created by Adam Wulf on 11/13/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "NaiveDrawRectRenderer.h"
#import "MMAbstractBezierPathElement.h"


@implementation NaiveDrawRectRenderer

- (void)drawModelDidUpdate:(MMDrawModel *)drawModel withBounds:(CGRect)bounds
{
    [super drawModelDidUpdate:drawModel withBounds:bounds];

    [self setNeedsDisplay];
}

@end
