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

@property(nonatomic, assign) BOOL dynamicWidth;
@property(nonatomic, assign, nullable) MMDrawModel *model;

- (void)drawRect:(CGRect)rect inContext:(CGContextRef)context;

@end

NS_ASSUME_NONNULL_END
