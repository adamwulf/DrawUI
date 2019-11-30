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

- (void)drawView:(MMDrawView *)drawView didUpdateModel:(MMDrawModel *)drawModel
{
    [super drawView:drawView didUpdateModel:drawModel];

    [self setNeedsDisplay];
}

@end
