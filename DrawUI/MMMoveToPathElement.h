//
//  DotSegment.h
//  JotUI
//
//  Created by Adam Wulf on 12/19/12.
//  Copyright (c) 2012 Milestone Made. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMAbstractBezierPathElement.h"

/**
 * a moveto element represents the beginning of
 * a line segment, similar to the moveto 
 * CGPathElement
 */
@interface MMMoveToPathElement : MMAbstractBezierPathElement <NSSecureCoding>

+ (id)elementWithMoveTo:(CGPoint)point;

@end
