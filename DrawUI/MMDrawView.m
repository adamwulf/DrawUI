//
//  MMInfiniteView.m
//  infinite-draw
//
//  Created by Adam Wulf on 10/4/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "MMDrawView.h"
#import "MMSegmentSmoother.h"
#import "MMAbstractBezierPathElement.h"
#import "MMMoveToPathElement.h"
#import "MMCurveToPathElement.h"
#import "MMDrawnStroke.h"


@implementation MMDrawView

#pragma mark - Properties

-(void)setDrawModel:(MMDrawModel*)drawModel{
    [[self renderer] drawView:self willUpdateModel:_drawModel to:drawModel];
    _drawModel = drawModel;
    [[self renderer] drawView:self didUpdateModel:drawModel];
}

#pragma mark - Drawing

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[self renderer] drawView:self willUpdateModel:[self drawModel] to:[self drawModel]];
    [[self drawModel] touchesBegan:touches withEvent:event inView:self];
    [[self renderer] drawView:self didUpdateModel:[self drawModel]];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[self renderer] drawView:self willUpdateModel:[self drawModel] to:[self drawModel]];
    [[self drawModel] touchesMoved:touches withEvent:event inView:self];
    [[self renderer] drawView:self didUpdateModel:[self drawModel]];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[self renderer] drawView:self willUpdateModel:[self drawModel] to:[self drawModel]];
    [[self drawModel] touchesEnded:touches withEvent:event inView:self];
    [[self renderer] drawView:self didUpdateModel:[self drawModel]];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[self renderer] drawView:self willUpdateModel:[self drawModel] to:[self drawModel]];
    [[self drawModel] touchesCancelled:touches withEvent:event inView:self];
    [[self renderer] drawView:self didUpdateModel:[self drawModel]];
}


@end
