//
//  MMTouchStream.h
//  DrawUI
//
//  Created by Adam Wulf on 11/15/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMTouchStreamEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface MMTouchStream : NSObject

/// Add a touch to the stream and returns its event
- (MMTouchStreamEvent *)addStreamEvent:(UITouch *)touch velocity:(CGFloat)velocity;

/// Returns all events that have occurred since the input event.
/// Returns all events in the stream if the input is nil
- (NSArray<MMTouchStreamEvent *> *)eventsSinceToken:(nullable MMTouchStreamEvent *)event;

@end

NS_ASSUME_NONNULL_END
