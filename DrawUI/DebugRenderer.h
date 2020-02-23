//
//  DebugRenderer.h
//  DrawUI
//
//  Created by Adam Wulf on 11/17/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMDrawViewRenderer.h"

NS_ASSUME_NONNULL_BEGIN


@interface DebugRenderer : UIView <MMDrawViewRenderer>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithView:(UIView *)canvasView;

@end

NS_ASSUME_NONNULL_END
