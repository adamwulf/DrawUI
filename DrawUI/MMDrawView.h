//
//  MMInfiniteView.h
//  infinite-draw
//
//  Created by Adam Wulf on 10/4/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMDrawModel.h"

NS_ASSUME_NONNULL_BEGIN

@class MMDrawView, MMPen;

@protocol MMDrawViewRenderer <NSObject>

-(void)drawView:(MMDrawView*)drawView willUpdateModel:(MMDrawModel*)oldModel to:(MMDrawModel*)newModel;
-(void)drawView:(MMDrawView*)drawView didUpdateModel:(MMDrawModel*)drawModel;

@end

@interface MMDrawView : UIView

@property(nonatomic, strong) NSObject<MMDrawViewRenderer>* renderer;
@property(nonatomic, strong) MMDrawModel* drawModel;
@property(nonatomic, strong) MMPen* tool;

@end

NS_ASSUME_NONNULL_END
