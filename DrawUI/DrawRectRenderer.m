//
//  DrawRectRenderer.m
//  DrawUI
//
//  Created by Adam Wulf on 11/13/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "DrawRectRenderer.h"

@interface DrawRectRenderer ()

@property (nonatomic, strong) MMDrawModel *model;

@end

@implementation DrawRectRenderer

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
    
    [self setNeedsDisplay];
}

-(void)drawView:(MMDrawView *)drawView didUpdateModel:(MMDrawModel *)drawModel{
    _model = drawModel;
}

-(void)drawRect:(CGRect)rect{
    for (MMDrawnStroke *stroke in [[self model] strokes]) {
        UIBezierPath *path = [stroke path];
        [path setLineWidth:2];
        
        [[UIColor blackColor] setStroke];
        [path stroke];
    }

    UIBezierPath *path = [[[self model] stroke] path];
    [path setLineWidth:2];
    
    [[UIColor blackColor] setStroke];
    [path stroke];
}

@end
