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

- (instancetype)initWithView:(UIView *)canvasView;

@end

NS_ASSUME_NONNULL_END
