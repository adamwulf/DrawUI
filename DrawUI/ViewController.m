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
#import "MMThumbnailRenderer.h"
#import "MMTouchVelocityGestureRecognizer.h"

@interface ViewController ()

@property(nonatomic, strong) IBOutlet MMDrawView *drawView;
@property(nonatomic, strong) IBOutlet UISegmentedControl *rendererControl;

@property(nonatomic, strong) MMDrawModel *drawModel;
@property(nonatomic, strong) MMPen *tool;
@property(nonatomic, strong) NSObject<MMDrawViewRenderer> *currentRenderer;

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

    [[self view] setBackgroundColor:[UIColor colorWithWhite:.8 alpha:1]];


    [[self drawView] setTool:[self tool]];
    [[self drawView] setDrawModel:[self drawModel]];

    MMThumbnailRenderer *thumbnailRenderer = [[MMThumbnailRenderer alloc] init];

    // install thumbnail generation
    [[self drawView] installRenderer:thumbnailRenderer];

    // also install the renderer to the UI
    [self didChangeRenderer:[self rendererControl]];
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
        [[self drawView] setDrawModel:_drawModel];
    }
}

- (IBAction)clearDrawing:(id)sender
{
    _drawModel = [[MMDrawModel alloc] init];

    [[self drawView] setDrawModel:[self drawModel]];
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
    if (_currentRenderer) {
        [[self drawView] uninstallRenderer:_currentRenderer];
    }

    if ([segmentedControl selectedSegmentIndex] == 0) {
        _currentRenderer = [[CALayerRenderer alloc] init];
    } else if ([segmentedControl selectedSegmentIndex] == 1) {
        _currentRenderer = [[CATiledLayerRenderer alloc] init];
    } else if ([segmentedControl selectedSegmentIndex] == 2) {
        _currentRenderer = [[NaiveDrawRectRenderer alloc] init];
    } else if ([segmentedControl selectedSegmentIndex] == 3) {
        _currentRenderer = [[SmartDrawRectRenderer alloc] init];
    } else if ([segmentedControl selectedSegmentIndex] == 4) {
        _currentRenderer = [[DebugRenderer alloc] init];
    }

    [_currentRenderer setDynamicWidth:YES];

    [[self drawView] installRenderer:_currentRenderer];
}

- (IBAction)redraw:(id)sender
{
    [[self drawView] setDrawModel:[[[self drawView] drawModel] copy]];
}


@end
