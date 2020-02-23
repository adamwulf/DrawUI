//
//  CALayerRenderer.h
//  DrawUI
//
//  Created by Adam Wulf on 11/12/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMCanCacheEraser.h"
#import "MMDrawViewRenderer.h"

NS_ASSUME_NONNULL_BEGIN

/// CALayerRenderer provides vector inked strokes with rasterized eraser strokes. Ink is drawn with
/// CAShapeLayers, and the eraser is rendered by a mask on those inked layers. Each time a
/// ink/eraser is toggled, a new layer and mask is created. All neighboring eraser strokes share the same
/// mask layer which saves some memory.
///
/// There are two ways to render eraser strokes: cached or realtime. A cached eraser will cache
/// the mask to a bitmap context so that each additional eraser stroke will be drawn in constant time.
/// A realtime eraser will redraw all eraser paths in the affected area.
///
/// The benefit of a realtime eraser is that it can render a predicted path for the eraser, and then update
/// the path correctly, while the cached eraser will draw faster but will not be able to benefit from predicted touches
@interface CALayerRenderer : NSObject <MMDrawViewRenderer, MMCanCacheEraser>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithView:(UIView *)canvasView;

/// YES to cache the eraser layer contents to a bitmap, NO to redraw the eraser layer each update
@property(nonatomic, assign) BOOL useCachedEraserLayerType;

@property(nonatomic, strong) MMDrawModel *drawModel;

@end

NS_ASSUME_NONNULL_END
