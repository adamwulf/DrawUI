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

@class MMDrawView;

@interface MMDrawModel : NSObject

@property(nonatomic, strong) MMDrawnStroke *stroke;
@property(nonatomic, strong) NSMutableArray<MMDrawnStroke *> *strokes;

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inView:(MMDrawView*)drawView;
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inView:(MMDrawView*)drawView;
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inView:(MMDrawView*)drawView;
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inView:(MMDrawView*)drawView;

@end

NS_ASSUME_NONNULL_END
