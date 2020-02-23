//
//  MMTouchStreamGestureRecognizer.h
//  DrawUI
//
//  Created by Adam Wulf on 2/23/20.
//  Copyright © 2020 Milestone Made. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMTouchStream.h"

NS_ASSUME_NONNULL_BEGIN


@interface MMTouchStreamGestureRecognizer : UIGestureRecognizer

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTarget:(nullable id)target action:(nullable SEL)action NS_UNAVAILABLE;
- (instancetype)initWithTouchStream:(MMTouchStream *)touchStream target:(nullable id)target action:(nullable SEL)action;

@property(nonatomic, strong, readonly) MMTouchStream *touchStream;

@end

NS_ASSUME_NONNULL_END
