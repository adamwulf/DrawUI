//
//  MMDrawModel.h
//  DrawUI
//
//  Created by Adam Wulf on 11/12/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMDrawnStroke.h"

NS_ASSUME_NONNULL_BEGIN

@class MMDrawView, MMTouchStream;

@interface MMDrawModel : NSObject <NSSecureCoding>

@property(nonatomic, strong) MMDrawnStroke *stroke;
@property(nonatomic, strong) NSMutableArray<MMDrawnStroke *> *strokes;

- (void)processTouchStream:(MMTouchStream *)touchStream withTool:(MMPen *)tool;

@end

NS_ASSUME_NONNULL_END
