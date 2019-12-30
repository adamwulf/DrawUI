//
//  AbstractSegment.h
//  MMDrawUI
//
//  Created by Adam Wulf on 12/19/12.
//  Copyright (c) 2012 Milestone Made. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMTouchStreamEvent.h"

@interface MMAbstractBezierPathElement : NSObject <NSSecureCoding, NSCopying>

@property(nonatomic, readonly) NSString *identifier;
@property(nonatomic, readonly) CGFloat width;
@property(nonatomic, readonly) CGPoint startPoint;
@property(nonatomic, readonly) CGPoint endPoint;
@property(nonatomic, readonly) CGRect bounds;

@property(nonatomic, readonly) UIBezierPath *borderPath;

@property(nonatomic, weak, readonly) MMAbstractBezierPathElement *nextElement;
@property(nonatomic, weak, readonly) MMAbstractBezierPathElement *previousElement;
@property(nonatomic, readonly) BOOL followsMoveTo;
@property(nonatomic, readonly, getter=isUpdated) BOOL updated;
@property(nonatomic, readonly, getter=isPrediction) BOOL prediction;
/// Used by renderers to determine when a stroke was last updated
@property(nonatomic, assign) NSUInteger version;

- (CGFloat)lengthOfElement;
- (CGFloat)angleOfStart;
- (CGFloat)angleOfEnd;
- (void)adjustStartBy:(CGPoint)adjustment;
- (UIBezierPath *)bezierPathSegment;

- (void)updateWithEvent:(MMTouchStreamEvent *)event width:(CGFloat)width NS_REQUIRES_SUPER;

@end
