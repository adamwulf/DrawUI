//
//  CALayerRenderer.h
//  DrawUI
//
//  Created by Adam Wulf on 11/12/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMDrawView.h"
#import "MMCanCacheEraser.h"

NS_ASSUME_NONNULL_BEGIN


@interface CALayerRenderer : NSObject <MMDrawViewRenderer, MMCanCacheEraser>

/// YES to cache the eraser layer contents to a bitmap, NO to redraw the eraser layer each update
@property(nonatomic, assign) BOOL useCachedEraserLayerType;

@end

NS_ASSUME_NONNULL_END
