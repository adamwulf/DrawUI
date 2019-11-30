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

    _tool = [[MMPen alloc] initWithMinSize:2 andMaxSize:7];
    _drawModel = [[MMDrawModel alloc] init];

    [self didChangeRenderer:[self rendererControl]];

    [[self view] setBackgroundColor:[UIColor colorWithWhite:.9 alpha:1]];
}

- (IBAction)saveDrawing:(id)sender
{
    NSError *error;

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:documentsDirectory];
    url = [url URLByAppendingPathComponent:@"drawing.dat"];

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_drawModel requiringSecureCoding:YES error:&error];

    if (error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error Saving Data" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){

                         }]];

        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [data writeToURL:url atomically:YES];

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Saved!" message:@"The drawing is saved" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){

                         }]];

        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)loadDrawing:(id)sender
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:documentsDirectory];
    url = [url URLByAppendingPathComponent:@"drawing.dat"];

    NSData *data = [NSData dataWithContentsOfURL:url];
    NSError *error;

    _drawModel = [NSKeyedUnarchiver unarchivedObjectOfClass:[MMDrawModel class] fromData:data error:&error];

    if (error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error Loading Data" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){

                         }]];

        [self presentViewController:alert animated:YES completion:nil];
    } else {
        // build a new renderer and set its model
        [self didChangeRenderer:[self rendererControl]];
    }
}

- (IBAction)clearDrawing:(id)sender
{
    _drawModel = [[MMDrawModel alloc] init];

    [self didChangeRenderer:[self rendererControl]];
}

- (IBAction)changeTool:(UISegmentedControl *)toolPicker
{
    if (toolPicker.selectedSegmentIndex == 0) {
        _tool = [[MMPen alloc] initWithMinSize:2 andMaxSize:7];
        [_tool setColor:[UIColor blackColor]];
    } else {
        _tool = [[MMPen alloc] initWithMinSize:20 andMaxSize:20];
        [_tool setColor:nil];
    }

    [[self drawView] setTool:[self tool]];
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
