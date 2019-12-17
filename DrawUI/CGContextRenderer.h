//
//  CGContextRenderer.h
//  DrawUI
//
//  Created by Adam Wulf on 12/17/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "MMDrawView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CGContextRenderer : NSObject

/// set to YES to daw variable width strokes, NO for fixed width strokes
@property(nonatomic, assign) BOOL dynamicWidth;
/// set to YES to draw only new strokes since last render, NO to draw all strokes
@property(nonatomic, assign) BOOL drawByDiff;
/// this model's strokes will be rendered during any call to drawRect:inContext:
@property(nonatomic, assign, nullable) MMDrawModel *model;

/// draw the model's strokes to the input context
- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context;

@end

NS_ASSUME_NONNULL_END
