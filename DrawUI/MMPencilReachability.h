//
//  MMPencilReachability.h
//  infinite-draw
//
//  Created by Adam Wulf on 10/7/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const MMPencilReachabilityChangedNotification;


@interface MMPencilReachability : NSObject

@property(nonatomic, readonly, getter=isPencilConnected) BOOL pencilConnected;

@end

NS_ASSUME_NONNULL_END
