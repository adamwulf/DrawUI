//
//  CALayerRenderer.h
//  DrawUI
//
//  Created by Adam Wulf on 11/12/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMDrawView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CALayerRenderer : NSObject<MMDrawViewRenderer>

@property (nonatomic, assign) BOOL dynamicWidth;

@end

NS_ASSUME_NONNULL_END
