//
//  MMThumbnailRenderer.h
//  DrawUI
//
//  Created by Adam Wulf on 12/17/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMDrawViewRenderer.h"

NS_ASSUME_NONNULL_BEGIN


@interface MMThumbnailRenderer : NSObject <MMDrawViewRenderer>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
