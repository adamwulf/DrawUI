//
//  MMInfiniteView.h
//  infinite-draw
//
//  Created by Adam Wulf on 10/4/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDrawModel.h"
#import "MMDrawViewRenderer.h"

NS_ASSUME_NONNULL_BEGIN

@interface MMDrawView : UIView

@property(nonatomic, strong) NSObject<MMDrawViewRenderer> *renderer;
@property(nonatomic, strong) MMDrawModel *drawModel;
@property(nonatomic, strong) MMPen *tool;

@end

NS_ASSUME_NONNULL_END
