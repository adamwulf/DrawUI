//
//  MMDrawViewRenderer.h
//  DrawUI
//
//  Created by Adam Wulf on 12/17/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#ifndef MMDrawViewRenderer_h
#define MMDrawViewRenderer_h

@class MMDrawView, MMPen;

@protocol MMDrawViewRenderer <NSObject>

@property(nonatomic, assign) BOOL dynamicWidth;

- (void)installIntoDrawView:(MMDrawView *)drawView;
- (void)uninstallFromDrawView:(MMDrawView *)drawView;
- (void)drawView:(MMDrawView *)drawView willUpdateModel:(MMDrawModel *)oldModel;
- (void)drawView:(MMDrawView *)drawView didUpdateModel:(MMDrawModel *)drawModel;

- (void)drawView:(MMDrawView *)drawView willReplaceModel:(MMDrawModel *)oldModel withModel:(MMDrawModel *)newModel;
- (void)drawView:(MMDrawView *)drawView didReplaceModel:(MMDrawModel *)oldModel withModel:(MMDrawModel *)newModel;

@end

#endif /* MMDrawViewRenderer_h */
