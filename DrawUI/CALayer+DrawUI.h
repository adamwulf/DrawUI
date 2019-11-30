//
//  CALayer+DrawUI.h
//  DrawUI
//
//  Created by Adam Wulf on 11/29/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (DrawUI)

@property(nonatomic, assign, getter=isEraser) BOOL eraser;
@property(nonatomic, assign) NSUInteger eraserDepth;

@end

NS_ASSUME_NONNULL_END
