//
//  UITouch+MMDrawUI.m
//  DrawUI
//
//  Created by Adam Wulf on 12/30/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "UITouch+MMDrawUI.h"
#import <objc/runtime.h>


@implementation UITouch (MMDrawUI)

static char TOUCH_IDENTIFIER;

- (NSString *)identifier
{
    id identifier = objc_getAssociatedObject(self, &TOUCH_IDENTIFIER);

    if (!identifier) {
        identifier = [[NSUUID UUID] UUIDString];
        objc_setAssociatedObject(self, &TOUCH_IDENTIFIER, identifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return identifier;
}

@end
