//
//  CAEraserLayer.m
//  DrawUI
//
//  Created by Adam Wulf on 2/21/20.
//  Copyright © 2020 Milestone Made. All rights reserved.
//

#import "CAEraserLayer.h"


@implementation CAEraserLayer

@synthesize fillColor;
@synthesize strokeColor;
@synthesize lineWidth;


- (instancetype)initWithBounds:(CGRect)bounds
{
    if (self = [super init]) {
        [self setBounds:bounds];
    }
    return self;
}

- (void)setPath:(UIBezierPath *)path forIdentifier:(NSString *)identifier
{
}

@end
