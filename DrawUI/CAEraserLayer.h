//
//  CAEraserLayer.h
//  DrawUI
//
//  Created by Adam Wulf on 11/30/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@class MMDrawnStroke;

@interface CAEraserLayer : CALayer

@property(nonatomic, strong, readonly) CALayer *originalCanvas;

- (void)setupWithCanvas:(CALayer *)canvas andStroke:(MMDrawnStroke *)stroke;

@end

NS_ASSUME_NONNULL_END
