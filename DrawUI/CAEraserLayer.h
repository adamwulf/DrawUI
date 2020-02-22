//
//  CAEraserLayer.h
//  DrawUI
//
//  Created by Adam Wulf on 2/21/20.
//  Copyright © 2020 Milestone Made. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface CAEraserLayer : CALayer

@property(nonatomic) UIColor *fillColor;
@property(nonatomic) UIColor *strokeColor;
@property(nonatomic) CGFloat lineWidth;
@property(nonatomic) NSUInteger version;

- (instancetype)initWithBounds:(CGRect)bounds;

- (void)setPath:(UIBezierPath *)path forIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
