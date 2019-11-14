//
//  SmartDrawRectRenderer.h
//  DrawUI
//
//  Created by Adam Wulf on 11/13/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDrawView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SmartDrawRectRenderer : UIView<MMDrawViewRenderer>

@property (nonatomic, assign) BOOL filledPath;
@property (nonatomic, assign) BOOL dynamicWidth;

@end

NS_ASSUME_NONNULL_END
