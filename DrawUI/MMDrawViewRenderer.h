//
//  MMDrawViewRenderer.h
//  DrawUI
//
//  Created by Adam Wulf on 12/17/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#ifndef MMDrawViewRenderer_h
#define MMDrawViewRenderer_h

#import <UIKit/UIKit.h>

@class MMDrawModel, MMPen;

@protocol MMDrawViewRenderer <NSObject>

/// YES if the renderer should adjust the width throughout the stroke
/// NO for strokes to have uniform width
@property(nonatomic, assign) BOOL dynamicWidth;

- (void)didUpdateModel:(MMDrawModel *)drawModel;

@optional

- (void)willUpdateModel:(MMDrawModel *)oldModel;
- (void)didUpdateBounds:(CGRect)bounds;

- (void)installWithDrawModel:(MMDrawModel *)drawModel;
- (void)uninstall;

- (void)willReplaceModel:(MMDrawModel *)oldModel withModel:(MMDrawModel *)newModel;
- (void)didReplaceModel:(MMDrawModel *)oldModel withModel:(MMDrawModel *)newModel;

@end

#endif /* MMDrawViewRenderer_h */
