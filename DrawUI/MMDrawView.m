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
#import "MMTouchStream.h"
#import "MMTouchVelocityGestureRecognizer.h"

@interface MMDrawView ()

@property(nonatomic, strong) MMTouchStream *touchStream;

@end

@implementation MMDrawView

#pragma mark - Properties

- (void)setDrawModel:(MMDrawModel *)drawModel
{
    _touchStream = [[MMTouchStream alloc] init];

    [[self renderer] drawView:self willUpdateModel:_drawModel to:drawModel];
    _drawModel = drawModel;
    [[self renderer] drawView:self didUpdateModel:drawModel];
}

#pragma mark - Drawing

- (void)drawTouches:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    for (UITouch *touch in touches) {
        NSArray<UITouch *> *coalesced = [event coalescedTouchesForTouch:touch];
        if (![coalesced count]) {
            coalesced = @[touch];
        }

        for (UITouch *coalescedTouch in coalesced) {
            [_touchStream addStreamEvent:touch velocity:[[MMTouchVelocityGestureRecognizer sharedInstance] normalizedVelocityForTouch:coalescedTouch]];
        }
    }
}

#pragma mark - Events

- (void)touchesEstimatedPropertiesUpdated:(NSSet<UITouch *> *)touches
{
    [self drawTouches:touches withEvent:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self drawTouches:touches withEvent:event];

    [[self renderer] drawView:self willUpdateModel:[self drawModel] to:[self drawModel]];
    [[self drawModel] touchesBegan:touches withEvent:event inView:self];
    [[self renderer] drawView:self didUpdateModel:[self drawModel]];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self drawTouches:touches withEvent:event];

    [[self renderer] drawView:self willUpdateModel:[self drawModel] to:[self drawModel]];
    [[self drawModel] touchesMoved:touches withEvent:event inView:self];
    [[self renderer] drawView:self didUpdateModel:[self drawModel]];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self drawTouches:touches withEvent:event];

    [[self renderer] drawView:self willUpdateModel:[self drawModel] to:[self drawModel]];
    [[self drawModel] touchesEnded:touches withEvent:event inView:self];
    [[self renderer] drawView:self didUpdateModel:[self drawModel]];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self drawTouches:touches withEvent:event];

    [[self renderer] drawView:self willUpdateModel:[self drawModel] to:[self drawModel]];
    [[self drawModel] touchesCancelled:touches withEvent:event inView:self];
    [[self renderer] drawView:self didUpdateModel:[self drawModel]];
}

@end
