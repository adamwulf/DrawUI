//
//  ViewController.m
//  DrawUI
//
//  Created by Adam Wulf on 11/12/19.
//  Copyright © 2019 Milestone Made. All rights reserved.
//

#import "ViewController.h"
#import "MMDrawModel.h"
#import "DebugRenderer.h"
#import "CALayerRenderer.h"
#import "NaiveDrawRectRenderer.h"
#import "SmartDrawRectRenderer.h"
#import "CATiledLayerRenderer.h"
#import "MMThumbnailRenderer.h"
#import "MMTouchVelocityGestureRecognizer.h"
#import "MMTouchStreamGestureRecognizer.h"

CGFloat const kScale = 4;


@interface ViewController ()

@property(nonatomic, strong) IBOutlet UIView *drawView;
@property(nonatomic, strong) IBOutlet UISegmentedControl *rendererControl;
@property(nonatomic, strong) IBOutlet UISegmentedControl *scaleControl;
@property(nonatomic, strong) IBOutlet UISwitch *dynamicWidthSwitch;
@property(nonatomic, strong) IBOutlet UILabel *cachedEraserLabel;
@property(nonatomic, strong) IBOutlet UISwitch *cachedEraserSwitch;

@property(nonatomic, strong) MMDrawModel *drawModel;
@property(nonatomic, strong) MMPen *tool;
@property(nonatomic, strong) NSMutableArray<NSObject<MMDrawViewRenderer> *> *allRenderers;
@property(nonatomic, strong) NSObject<MMDrawViewRenderer> *currentRenderer;

@property(nonatomic, strong) MMTouchStreamGestureRecognizer *touchGesture;

@property(nonatomic, strong) IBOutlet NSLayoutConstraint *widthConstraint;
@property(nonatomic, strong) IBOutlet NSLayoutConstraint *heightConstraint;

@property(nonatomic, strong) NSLayoutConstraint *widthConstraint2;
@property(nonatomic, strong) NSLayoutConstraint *heightConstraint2;

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
    _allRenderers = [NSMutableArray array];

    [[self view] setBackgroundColor:[UIColor colorWithWhite:.8 alpha:1]];

    [self setDrawModel:[self drawModel]];

    [_allRenderers addObject:[[MMThumbnailRenderer alloc] initWithFrame:[[self view] bounds]]];

    [[_allRenderers lastObject] setDrawModel:[self drawModel]];

    // also install the renderer to the UI
    [self didChangeRenderer:[self rendererControl]];

    _widthConstraint2 = [NSLayoutConstraint constraintWithItem:[_widthConstraint firstItem] attribute:[_widthConstraint firstAttribute] relatedBy:[_widthConstraint relation] toItem:[_widthConstraint secondItem] attribute:[_widthConstraint secondAttribute] multiplier:kScale constant:0];
    _heightConstraint2 = [NSLayoutConstraint constraintWithItem:[_heightConstraint firstItem] attribute:[_heightConstraint firstAttribute] relatedBy:[_heightConstraint relation] toItem:[_heightConstraint secondItem] attribute:[_heightConstraint secondAttribute] multiplier:kScale constant:0];

    // re-render whenever our size changes. Some renderers would otherwise stretch to fill the new size
    [[self drawView] addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - Refresh Renderers

- (void)setDrawModel:(MMDrawModel *)newModel
{
    _drawModel = newModel;

    for (NSObject<MMDrawViewRenderer> *renderer in _allRenderers) {
        [renderer setDrawModel:newModel];
    }

    [self refreshGestureForModel:[self drawModel]];
}

- (void)refreshGestureForModel:(MMDrawModel *)newModel
{
    if (_touchGesture) {
        [[self drawView] removeGestureRecognizer:_touchGesture];
    }

    _touchGesture = [[MMTouchStreamGestureRecognizer alloc] initWithTouchStream:[newModel touchStream] target:self action:@selector(touchStreamGesture:)];

    [[self drawView] addGestureRecognizer:_touchGesture];
}

#pragma mark - Notifications

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIView *)drawView change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context
{
    for (NSObject<MMDrawViewRenderer> *renderer in _allRenderers) {
        if ([renderer respondsToSelector:@selector(drawModelDidUpdateBounds:)]) {
            [renderer drawModelDidUpdate:[self drawModel] withBounds:[[self drawView] bounds]];
        }
    }
}

#pragma mark - Gestures

- (void)touchStreamGesture:(MMTouchStreamGestureRecognizer *)gesture
{
    switch ([gesture state]) {
        case UIGestureRecognizerStateBegan:
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded:
            [[self drawModel] processTouchStreamWithTool:[self tool]];

            for (NSObject<MMDrawViewRenderer> *renderer in _allRenderers) {
                [renderer drawModelDidUpdate:[self drawModel] withBounds:[[self drawView] bounds]];
            }
            break;
        default:
            break;
    }
}

#pragma mark - Actions

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

    MMDrawModel *drawModel = [NSKeyedUnarchiver unarchivedObjectOfClass:[MMDrawModel class] fromData:data error:&error];

    if (error) {
        DebugLog(@"Error Unarchiving: %@", error);

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error Loading Data" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action){

                         }]];

        [self presentViewController:alert animated:YES completion:nil];
    } else {
        // build a new renderer and set its model
        [self setDrawModel:drawModel];
    }
}

- (IBAction)clearDrawing:(id)sender
{
    _drawModel = [[MMDrawModel alloc] init];

    [self setDrawModel:[self drawModel]];
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
}

- (IBAction)didChangeRenderer:(UISegmentedControl *)segmentedControl
{
    if (_currentRenderer) {
        if ([_currentRenderer respondsToSelector:@selector(invalidate)]) {
            [_currentRenderer invalidate];
        }
        [[self allRenderers] removeObject:_currentRenderer];
    }

    if ([segmentedControl selectedSegmentIndex] == 0) {
        _currentRenderer = [[CALayerRenderer alloc] initWithView:[self drawView]];
    } else if ([segmentedControl selectedSegmentIndex] == 1) {
        _currentRenderer = [[CATiledLayerRenderer alloc] initWithView:[self drawView]];
    } else if ([segmentedControl selectedSegmentIndex] == 2) {
        _currentRenderer = [[NaiveDrawRectRenderer alloc] initWithView:[self drawView]];
    } else if ([segmentedControl selectedSegmentIndex] == 3) {
        _currentRenderer = [[SmartDrawRectRenderer alloc] initWithView:[self drawView]];
    } else if ([segmentedControl selectedSegmentIndex] == 4) {
        _currentRenderer = [[DebugRenderer alloc] initWithView:[self drawView]];
    }

    [[self allRenderers] addObject:_currentRenderer];

    // enable/disable dynamic width
    for (NSObject<MMDrawViewRenderer> *renderer in [self allRenderers]) {
        [renderer setDynamicWidth:[[self dynamicWidthSwitch] isOn]];
    }

    // enable disable custom renderer options
    BOOL cachedEraserVisible = [_currentRenderer conformsToProtocol:@protocol(MMCanCacheEraser)];

    [[self cachedEraserLabel] setHidden:!cachedEraserVisible];
    [[self cachedEraserSwitch] setHidden:!cachedEraserVisible];

    if ([_currentRenderer conformsToProtocol:@protocol(MMCanCacheEraser)]) {
        [(id<MMCanCacheEraser>)_currentRenderer setUseCachedEraserLayerType:[[self cachedEraserSwitch] isOn]];
    }

    [_currentRenderer setDrawModel:[self drawModel]];
}

- (IBAction)didChangeScale:(id)sender
{
    if ([_scaleControl selectedSegmentIndex] == 1) {
        [_widthConstraint setActive:NO];
        [_heightConstraint setActive:NO];
        [_widthConstraint2 setActive:YES];
        [_heightConstraint2 setActive:YES];
    } else {
        [_widthConstraint2 setActive:NO];
        [_heightConstraint2 setActive:NO];
        [_widthConstraint setActive:YES];
        [_heightConstraint setActive:YES];
    }

    if ([_scaleControl selectedSegmentIndex] == 2) {
        [_drawView setTransform:CGAffineTransformMakeScale(kScale, kScale)];
    } else {
        [_drawView setTransform:CGAffineTransformIdentity];
    }
}

- (IBAction)redraw:(id)sender
{
    [self setDrawModel:[[self drawModel] copy]];
}

- (IBAction)didChangeDynamicWidth:(id)sender
{
    // re-render the drawing with updated dynamic width
    [self didChangeRenderer:[self rendererControl]];
}

- (IBAction)didChangeCachedEraser:(id)sender
{
    // we changed our preference for bitmap caching the eraser
    [self didChangeRenderer:[self rendererControl]];
}


@end
