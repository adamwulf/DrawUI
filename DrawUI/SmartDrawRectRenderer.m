//
//  SmartDrawRectRenderer.m
//  DrawUI
//
//  Created by Adam Wulf on 11/13/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "SmartDrawRectRenderer.h"
#import "Constants.h"

@interface SmartDrawRectRenderer ()

@property (nonatomic, strong) MMDrawModel *model;

@end

@implementation SmartDrawRectRenderer

-(instancetype)init{
    if(self = [super init]){
        [self setOpaque:NO];
    }
    return self;
}

-(void)drawView:(MMDrawView *)drawView willUpdateModel:(MMDrawModel *)oldModel to:(MMDrawModel *)newModel{
    if([self superview] != drawView){
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        [drawView addSubview:self];
        
        [[[self leadingAnchor] constraintEqualToAnchor:[drawView leadingAnchor]] setActive:YES];
        [[[self trailingAnchor] constraintEqualToAnchor:[drawView trailingAnchor]] setActive:YES];
        [[[self topAnchor] constraintEqualToAnchor:[drawView topAnchor]] setActive:YES];
        [[[self bottomAnchor] constraintEqualToAnchor:[drawView bottomAnchor]] setActive:YES];
    }
}

-(void)drawView:(MMDrawView *)drawView didUpdateModel:(MMDrawModel *)drawModel{
    _model = drawModel;

    MMDrawnStroke *stroke = [drawModel stroke] ?: [[drawModel strokes] lastObject];
    
    if(stroke){
        CGRect pathBounds = [[stroke path] bounds];
        
        pathBounds = CGRectInset(pathBounds, -kStrokeWidth, -kStrokeWidth);

        [self setNeedsDisplayInRect:pathBounds];
    }
}

-(void)drawRect:(CGRect)rect{
    for (MMDrawnStroke *stroke in [[self model] strokes]) {
        [self renderStroke:stroke inRect:rect];
    }
    
    [self renderStroke:[[self model] stroke] inRect:rect];
}

-(void)renderStroke:(MMDrawnStroke*)stroke inRect:(CGRect)rect{
    if([self filledPath]){
        UIBezierPath *path = [stroke path];
        
        if(path){
            CGPathGetBoundingBox(nil);
            CGPathGetPathBoundingBox(nil);
            
            UIBezierPath *widePath = [UIBezierPath bezierPathWithCGPath:CGPathCreateCopyByStrokingPath([path CGPath], nil, kStrokeWidth, kCGLineCapRound, kCGLineJoinRound, kStrokeWidth)];
            CGRect pathBounds = [widePath bounds];
            
            pathBounds = CGRectInset(pathBounds, -kStrokeWidth, -kStrokeWidth);

            if(widePath && CGRectIntersectsRect(pathBounds, rect)){
                [[UIColor blackColor] setFill];
                [widePath fill];
            }
        }
    }else{
        UIBezierPath *path = [stroke path];
        CGRect pathBounds = [[stroke path] bounds];
        
        pathBounds = CGRectInset(pathBounds, -kStrokeWidth, -kStrokeWidth);

        if(path && CGRectIntersectsRect(pathBounds, rect)){
            [path setLineWidth:kStrokeWidth];
            
            [[UIColor blackColor] setStroke];
            [path stroke];
        }
    }
}

@end
