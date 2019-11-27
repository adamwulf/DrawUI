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
#import "DebugRenderer.h"
#import "CALayerRenderer.h"
#import "NaiveDrawRectRenderer.h"
#import "SmartDrawRectRenderer.h"
#import "CATiledLayerRenderer.h"
#import "MMTouchVelocityGestureRecognizer.h"

@interface ViewController ()

@property(nonatomic, strong) IBOutlet MMDrawView *drawView;
@property(nonatomic, strong) IBOutlet UISegmentedControl *rendererControl;

@property(nonatomic, strong) MMDrawModel *drawModel;
@property(nonatomic, strong) MMPen *tool;

@end

@implementation ViewController
@dynamic view;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [[self view] addGestureRecognizer:[MMTouchVelocityGestureRecognizer sharedInstance]];

    _tool = [[MMPen alloc] initWithMinSize:2 andMaxSize:17];
    _drawModel = [[MMDrawModel alloc] init];

    [self didChangeRenderer:[self rendererControl]];
}

- (IBAction)didChangeRenderer:(UISegmentedControl *)segmentedControl
{
    [[self drawView] removeFromSuperview];

    _drawView = [[MMDrawView alloc] init];

    [[self drawView] setTranslatesAutoresizingMaskIntoConstraints:NO];
    [[self view] insertSubview:[self drawView] atIndex:0];

    [[[[self drawView] leftAnchor] constraintEqualToAnchor:[[self view] leftAnchor]] setActive:YES];
    [[[[self drawView] rightAnchor] constraintEqualToAnchor:[[self view] rightAnchor]] setActive:YES];
    [[[[self drawView] topAnchor] constraintEqualToAnchor:[[self view] topAnchor]] setActive:YES];
    [[[[self drawView] bottomAnchor] constraintEqualToAnchor:[[self view] bottomAnchor]] setActive:YES];

    NSObject<MMDrawViewRenderer> *renderer;

    if ([segmentedControl selectedSegmentIndex] == 0) {
        renderer = [[CALayerRenderer alloc] init];
    } else if ([segmentedControl selectedSegmentIndex] == 1) {
        renderer = [[CATiledLayerRenderer alloc] init];
    } else if ([segmentedControl selectedSegmentIndex] == 2) {
        renderer = [[NaiveDrawRectRenderer alloc] init];
    } else if ([segmentedControl selectedSegmentIndex] == 3) {
        renderer = [[SmartDrawRectRenderer alloc] init];
    } else if ([segmentedControl selectedSegmentIndex] == 4) {
        renderer = [[DebugRenderer alloc] init];
    }

    if ([renderer respondsToSelector:@selector(setDynamicWidth:)]) {
        [(SmartDrawRectRenderer *)renderer setDynamicWidth:YES];
    }

    [[self drawView] setTool:[self tool]];
    [[self drawView] setRenderer:renderer];
    [[self drawView] setDrawModel:[self drawModel]];
}

- (IBAction)redraw:(id)sender
{
    [[self drawView] setNeedsDisplay];

    [[[self drawView] subviews] makeObjectsPerformSelector:@selector(setNeedsDisplay)];
}


@end
