//
//  DrawUI.h
//  DrawUI
//
//  Created by Adam Wulf on 1/4/20.
//  Copyright © 2020 Milestone Made. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for DrawUI.
FOUNDATION_EXPORT double DrawUIVersionNumber;

//! Project version string for DrawUI.
FOUNDATION_EXPORT const unsigned char DrawUIVersionString[];

#import <DrawUI/NSArray+MMDrawUI.h>
#import <DrawUI/UIColor+MMDrawUI.h>
#import <DrawUI/UITouch+MMDrawUI.h>
#import <DrawUI/CGContextRenderer.h>

#import <DrawUI/Constants.h>
#import <DrawUI/MMVector.h>
#import <DrawUI/MMTouchVelocityGestureRecognizer.h>
#import <DrawUI/MMPen.h>
#import <DrawUI/MMPencilReachability.h>

#import <DrawUI/MMTouchStream.h>
#import <DrawUI/MMTouchStreamEvent.h>
#import <DrawUI/MMDrawModel.h>

#import <DrawUI/MMDrawnStroke.h>
#import <DrawUI/MMAbstractBezierPathElement.h>
#import <DrawUI/MMCurveToPathElement.h>
#import <DrawUI/MMMoveToPathElement.h>
#import <DrawUI/MMSegmentSmoother.h>

#import <DrawUI/MMCanCacheEraser.h>
#import <DrawUI/MMDrawViewRenderer.h>
#import <DrawUI/MMDrawView.h>

#import <DrawUI/CALayerRenderer.h>
#import <DrawUI/CARealtimeEraserLayer.h>
#import <DrawUI/CACachedEraserLayer.h>
#import <DrawUI/CAPencilLayer.h>

#import <DrawUI/CATiledLayerRenderer.h>
#import <DrawUI/CANoFadeTiledLayer.h>

#import <DrawUI/NaiveDrawRectRenderer.h>
#import <DrawUI/SmartDrawRectRenderer.h>
#import <DrawUI/DebugRenderer.h>
#import <DrawUI/MMThumbnailRenderer.h>
