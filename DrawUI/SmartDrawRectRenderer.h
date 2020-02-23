//
//  SmartDrawRectRenderer.h
//  DrawUI
//
//  Created by Adam Wulf on 11/13/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDrawViewRenderer.h"

NS_ASSUME_NONNULL_BEGIN


@interface SmartDrawRectRenderer : UIView <MMDrawViewRenderer>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithView:(UIView *)canvasView;

@property(nonatomic, strong) MMDrawModel *drawModel;

@end

NS_ASSUME_NONNULL_END
