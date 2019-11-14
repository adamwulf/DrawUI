//
//  MMDrawnStroke.h
//  infinite-draw
//
//  Created by Adam Wulf on 10/5/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMPen.h"

NS_ASSUME_NONNULL_BEGIN

@class MMAbstractBezierPathElement;

@interface MMDrawnStroke : NSObject

- (instancetype)init;

@property(nonatomic, nullable, readonly) UIBezierPath *path;
@property(nonatomic, strong, readonly) NSArray<MMAbstractBezierPathElement *> *segments;

- (MMAbstractBezierPathElement*)addTouch:(UITouch *)touch inView:(UIView *)view smoothness:(CGFloat)smoothness width:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
