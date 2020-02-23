//
//  MMCanCacheEraser.h
//  DrawUI
//
//  Created by Adam Wulf on 2/21/20.
//  Copyright © 2020 Milestone Made. All rights reserved.
//

#import "MMDrawViewRenderer.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MMCanCacheEraser <MMDrawViewRenderer>

/// YES to cache the eraser layer contents to a bitmap, NO to redraw the eraser layer each update
@property(nonatomic, assign) BOOL useCachedEraserLayerType;

@end

NS_ASSUME_NONNULL_END
