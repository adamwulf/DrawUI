//
//  ViewController.m
//  DrawUI
//
//  Created by Adam Wulf on 11/12/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "ViewController.h"
#import "MMDrawView.h"
#import "MMDrawModel.h"
#import "CALayerRenderer.h"
#import "NaiveDrawRectRenderer.h"
#import "SmartDrawRectRenderer.h"
#import "CATiledLayerRenderer.h"
#import "MMTouchVelocityGestureRecognizer.h"

@interface ViewController ()

@property(nonatomic, strong) MMDrawView *view;
@property(nonatomic, strong) NSObject<MMDrawViewRenderer> *activeRenderer;

@end

@implementation ViewController
@dynamic view;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [[self view] addGestureRecognizer:[MMTouchVelocityGestureRecognizer sharedInstance]];

    //    _activeRenderer = [[CALayerRenderer alloc] init];
    //    _activeRenderer = [[NaiveDrawRectRenderer alloc] init];
    //    _activeRenderer = [[SmartDrawRectRenderer alloc] init];
    //    [_activeRenderer setDynamicWidth:YES];
    //    [(SmartDrawRectRenderer*)_activeRenderer setFilledPath:YES];
    _activeRenderer = [[CATiledLayerRenderer alloc] init];

    MMPen *pen = [[MMPen alloc] initWithMinSize:2 andMaxSize:7];

    [[self view] setTool:pen];
    [[self view] setRenderer:[self activeRenderer]];
    [[self view] setDrawModel:[[MMDrawModel alloc] init]];
}


@end
