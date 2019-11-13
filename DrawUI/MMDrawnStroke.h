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


@interface MMDrawnStroke : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPen:(MMPen *)pen;

@property(nonatomic, strong, readonly) MMPen *pen;
@property(nonatomic, nullable, readonly) UIBezierPath *path;

- (void)addTouch:(UITouch *)touch inView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
