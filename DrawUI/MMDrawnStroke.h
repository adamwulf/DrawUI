//
//  MMDrawnStroke.h
//  infinite-draw
//
//  Created by Adam Wulf on 10/5/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMPen.h"

NS_ASSUME_NONNULL_BEGIN

@class MMAbstractBezierPathElement, MMTouchStreamEvent;

@interface MMDrawnStroke : NSObject <NSSecureCoding, NSCopying>

- (instancetype)initWithTool:(MMPen *)tool;

@property(nonatomic, readonly) NSString *identifier;
@property(nonatomic, nullable, readonly) UIBezierPath *path;
@property(nonatomic, nullable, readonly) UIBezierPath *borderPath;
@property(nonatomic, strong, readonly) NSArray<MMAbstractBezierPathElement *> *segments;
@property(nonatomic, strong, readonly) MMPen *tool;
@property(nonatomic, strong, readonly) MMTouchStreamEvent *event;

- (MMAbstractBezierPathElement *)addEvent:(MMTouchStreamEvent *)event;
- (BOOL)containsEvent:(MMTouchStreamEvent *)event;

/// Used by renderers to determine when a stroke was last updated
@property(nonatomic, assign) NSUInteger version;

@end

NS_ASSUME_NONNULL_END
