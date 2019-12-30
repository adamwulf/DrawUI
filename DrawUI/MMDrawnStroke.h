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

/// The first event that created this stroke. the [event touchIdentifier] can be useful for mapping this stroke to a [UITouch identifier]
@property(nonatomic, strong, readonly) MMTouchStreamEvent *event;

- (MMAbstractBezierPathElement *)addEvent:(MMTouchStreamEvent *)event;

/// Returns YES if the stroke is waiting for updates from the input event, NO otherwise
- (BOOL)waitingForEvent:(MMTouchStreamEvent *)event;

/// Used by renderers to determine when a stroke was last updated
@property(nonatomic, assign) NSUInteger version;

@end

NS_ASSUME_NONNULL_END
