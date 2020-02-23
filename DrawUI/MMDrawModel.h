//
//  MMDrawModel.h
//  DrawUI
//
//  Created by Adam Wulf on 11/12/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMDrawnStroke.h"
#import "MMTouchStream.h"

NS_ASSUME_NONNULL_BEGIN

@class MMDrawView, MMTouchStream;


@interface MMDrawModel : NSObject <NSSecureCoding, NSCopying>

@property(nonatomic, strong, readonly) MMTouchStream *touchStream;
@property(nonatomic, strong) MMDrawnStroke *activeStroke;
@property(nonatomic, strong) NSMutableArray<MMDrawnStroke *> *strokes;

- (void)processTouchStreamWithTool:(MMPen *)tool;

@end

NS_ASSUME_NONNULL_END
