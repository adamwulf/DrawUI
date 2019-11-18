//
//  MMAbstractBezierPathElement-Protected.h
//  JotUI
//
//  Created by Adam Wulf on 5/22/13.
//  Copyright (c) 2013 Milestone Made. All rights reserved.
//

#ifndef JotUI_AbstractBezierPathElement_Protected_h
#define JotUI_AbstractBezierPathElement_Protected_h

#import "MMTouchStreamEvent.h"

@interface MMAbstractBezierPathElement ()

@property(nonatomic, assign) CGPoint startPoint;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat previousWidth;
@property(nonatomic, strong) NSArray<MMTouchStreamEvent *> *events;

@property(nonatomic, assign) BOOL bakedPreviousElementProps;
@property(nonatomic, assign) NSInteger renderVersion;

- (id)initWithStart:(CGPoint)point;

- (void)validateDataGivenPreviousElement:(MMAbstractBezierPathElement *)previousElement NS_REQUIRES_SUPER;

- (CGFloat)angleBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2;

@end


#endif
