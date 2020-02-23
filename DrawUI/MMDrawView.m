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
#import "MMTouchStreamGestureRecognizer.h"


@interface MMDrawView ()

@property(nonatomic, strong) NSMutableArray<NSObject<MMDrawViewRenderer> *> *renderers;

@end


@implementation MMDrawView {
    MMTouchStreamGestureRecognizer *_touchGesture;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self finishInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self finishInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self finishInit];
    }
    return self;
}

- (void)finishInit
{
    _renderers = [NSMutableArray array];

    // re-render whenever our size changes. Some renderers would otherwise stretch to fill the new size
    [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - Notifications

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIView *)drawView change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context
{
    for (NSObject<MMDrawViewRenderer> *renderer in [self renderers]) {
        if ([renderer respondsToSelector:@selector(drawView:didUpdateBounds:)]) {
            [renderer drawView:self didUpdateBounds:[self bounds]];
        }
    }
}

#pragma mark - Properties

- (void)setDrawModel:(MMDrawModel *)newModel
{
    if (_touchGesture) {
        [self removeGestureRecognizer:_touchGesture];
    }

    _touchGesture = [[MMTouchStreamGestureRecognizer alloc] initWithTouchStream:[newModel touchStream] target:self action:@selector(touchStreamGesture:)];

    [self addGestureRecognizer:_touchGesture];

    for (NSObject<MMDrawViewRenderer> *renderer in _renderers) {
        if ([renderer respondsToSelector:@selector(drawView:willReplaceModel:withModel:)]) {
            [renderer drawView:self willReplaceModel:_drawModel withModel:newModel];
        }
    }

    MMDrawModel *oldModel = _drawModel;
    _drawModel = newModel;

    for (NSObject<MMDrawViewRenderer> *renderer in _renderers) {
        if ([renderer respondsToSelector:@selector(drawView:didReplaceModel:withModel:)]) {
            [renderer drawView:self didReplaceModel:oldModel withModel:_drawModel];
        }
    }
}

- (void)uninstallRenderer:(NSObject<MMDrawViewRenderer> *)renderer
{
    if ([_renderers containsObject:renderer]) {
        if ([renderer respondsToSelector:@selector(uninstallFromDrawView:)]) {
            [renderer uninstallFromDrawView:self];
        }

        [_renderers removeObject:renderer];
    }
}

- (void)installRenderer:(NSObject<MMDrawViewRenderer> *)renderer
{
    [_renderers addObject:renderer];

    if ([renderer respondsToSelector:@selector(installIntoDrawView:)]) {
        [renderer installIntoDrawView:self];
    }
}

#pragma mark - Touch Stream

- (void)touchStreamGesture:(MMTouchStreamGestureRecognizer *)gesture
{
    switch ([gesture state]) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
            for (NSObject<MMDrawViewRenderer> *renderer in _renderers) {
                if ([renderer respondsToSelector:@selector(drawView:willUpdateModel:)]) {
                    [renderer drawView:self willUpdateModel:[self drawModel]];
                }
            }

            [[self drawModel] processTouchStreamWithTool:[self tool]];

            for (NSObject<MMDrawViewRenderer> *renderer in _renderers) {
                [renderer drawView:self didUpdateModel:[self drawModel]];
            }
            break;
        default:
            break;
    }
}

@end
