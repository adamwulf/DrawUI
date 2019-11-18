//
//  AbstractSegment.h
//  JotUI
//
//  Created by Adam Wulf on 12/19/12.
//  Copyright (c) 2012 Milestone Made. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMPlistSaving.h"
#import "MMTouchStreamEvent.h"

@interface MMAbstractBezierPathElement : NSObject <MMPlistSaving>

@property(nonatomic, readonly) NSString *identifier;
@property(nonatomic, readonly) CGFloat width;
@property(nonatomic, readonly) CGPoint startPoint;
@property(nonatomic, readonly) CGPoint endPoint;
@property(nonatomic, readonly) CGRect bounds;

@property(nonatomic, readonly) UIBezierPath *borderPath;

@property(nonatomic, readonly) BOOL followsMoveTo;
@property(nonatomic, readonly) CGFloat previousWidth;
@property(nonatomic, readonly, getter=isUpdated) BOOL updated;

- (CGFloat)lengthOfElement;
- (CGFloat)angleOfStart;
- (CGFloat)angleOfEnd;
- (void)adjustStartBy:(CGPoint)adjustment;
- (UIBezierPath *)bezierPathSegment;

- (void)scaleForWidth:(CGFloat)widthRatio andHeight:(CGFloat)heightRatio NS_REQUIRES_SUPER;

- (void)updateWithEvent:(MMTouchStreamEvent *)event;

@end
