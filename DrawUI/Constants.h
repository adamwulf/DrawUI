//
//  Constants.h
//  infinite-draw
//
//  Created by Adam Wulf on 10/5/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const kStrokeWidth;

typedef UICollectionViewLayoutAttributes MMLayoutAttributes;

#define kAbstractMethodException [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil]

#ifdef DEBUG
//#define DebugLog(__FORMAT__, ...)
#define DebugLog(__FORMAT__, ...) NSLog(__FORMAT__, ##__VA_ARGS__)
#else
#define DebugLog(__FORMAT__, ...)
#endif

static inline CGRect _CGSizeAspectFillFit(CGSize sizeToScale, CGSize sizeToFill, BOOL fill)
{
    CGFloat horizontalRatio = sizeToFill.width / sizeToScale.width;
    CGFloat verticalRatio = sizeToFill.height / sizeToScale.height;
    CGFloat ratio;
    if (fill) {
        ratio = MAX(horizontalRatio, verticalRatio); //AspectFill
    } else {
        ratio = MIN(horizontalRatio, verticalRatio); //AspectFill
    }

    CGSize scaledSize = CGSizeMake(sizeToScale.width * ratio, sizeToScale.height * ratio);

    return CGRectMake((sizeToFill.width - scaledSize.width) / 2, (sizeToFill.height - scaledSize.height) / 2, scaledSize.width, scaledSize.height);
}

#define PROPERTYNAME(name) NSStringFromSelector(@selector(name))

#define CGRectResizeBy(rect, dw, dh) CGRectMake(rect.origin.x, rect.origin.y, rect.size.width + dw, rect.size.height + dh)
#define CGRectGetMidPoint(rect) CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
#define CGRectFromSize(size) CGRectMake(0, 0, size.width, size.height)
#define CGRectFromPointSize(point, size) CGRectMake(point.x, point.y, size.width, size.height)
#define CGRectWithHeight(rect, height) CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, height)
#define CGSizeMaxDim(size) MAX((size).width, (size).height)
#define CGSizeSwap(size) CGSizeMake((size).height, (size).width)
#define CGPointSwap(point) CGPointMake((point).y, (point).x)
#define CGRectSquare(size) CGRectMake(0, 0, size, size)
#define CGPointScale(point, scale) CGPointMake(point.x *(scale), point.y *(scale))
#define CGSizeScale(size, scale) CGSizeMake(size.width *(scale), size.height *(scale))
#define CGRectScale(rect, scale) CGRectMake(rect.origin.x *(scale), rect.origin.y *(scale), rect.size.width *(scale), rect.size.height *(scale))
#define CGRectSwap(rect) CGRectMake((rect).origin.y, (rect).origin.x, (rect).size.height, (rect).size.width)
#define CGSizeFill(sizeToScale, sizeToFill) _CGSizeAspectFillFit(sizeToScale, sizeToFill, YES)
#define CGSizeFit(sizeToScale, sizeToFill) _CGSizeAspectFillFit(sizeToScale, sizeToFill, NO)
#define CGPointTranslate(point, translatex, translatey) CGPointMake((point).x + (translatex), (point).y + (translatey))
#define CGRectTranslate(rect, translatex, translatey) CGRectMake((rect).origin.x + (translatex), (rect).origin.y + (translatey), (rect).size.width, (rect).size.height)
#define CGPointNotFound CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX)

#define interpolate(s, e, p) (s * p + e * (1 - p))

#ifdef __cplusplus
extern "C" {
#endif

void CGContextSaveThenRestoreForBlock(CGContextRef __nonnull context, void (^__nonnull block)(void));

CGFloat DistanceBetweenTwoPoints(CGPoint point1, CGPoint point2);

CGFloat SquaredDistanceBetweenTwoPoints(CGPoint point1, CGPoint point2);

CGPoint NormalizePointTo(CGPoint point1, CGSize size);

CGPoint DenormalizePointTo(CGPoint point1, CGSize size);

CGPoint AveragePoints(CGPoint point1, CGPoint point2);


typedef struct Quadrilateral {
    CGPoint upperLeft;
    CGPoint upperRight;
    CGPoint lowerRight;
    CGPoint lowerLeft;
} Quadrilateral;

// interpolate between min/max with 0<=t<=1
CGFloat logTransform(CGFloat min, CGFloat max, CGFloat t);

CGFloat sqrtTransform(CGFloat min, CGFloat max, CGFloat t);

CGFloat sqTransform(CGFloat min, CGFloat max, CGFloat t);


#ifdef __cplusplus
}
#endif
