//
//  MMAbstractBezierPathElement-Protected.h
//  MMDrawUI
//
//  Created by Adam Wulf on 5/22/13.
//  Copyright (c) 2013 Milestone Made. All rights reserved.
//

#ifndef MMDrawUI_AbstractBezierPathElement_Protected_h
#define MMDrawUI_AbstractBezierPathElement_Protected_h

#import "MMTouchStreamEvent.h"

@interface MMAbstractBezierPathElement ()

@property(nonatomic, assign) CGPoint startPoint;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, strong) NSArray<MMTouchStreamEvent *> *events;

@property(nonatomic, assign) NSInteger renderVersion;

- (id)initWithStart:(CGPoint)point;

- (void)configurePreviousElement:(MMAbstractBezierPathElement *)previousElement NS_REQUIRES_SUPER;

- (CGFloat)angleBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2;

- (void)clearPathCaches;

@end


#endif
