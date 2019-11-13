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
#import "DrawRectRenderer.h"

@interface ViewController ()

@property(nonatomic, strong) MMDrawView* view;
@property(nonatomic, strong) NSObject<MMDrawViewRenderer>*activeRenderer;

@end

@implementation ViewController
@dynamic view;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    _activeRenderer = [[CALayerRenderer alloc] init];
    _activeRenderer = [[DrawRectRenderer alloc] init];

    [[self view] setTool:[[MMPen alloc] initWithMinSize:2 andMaxSize:6]];
    [[self view] setDrawModel:[[MMDrawModel alloc] init]];
    [[self view] setRenderer:[self activeRenderer]];
}


@end
