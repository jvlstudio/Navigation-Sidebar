//
//  PSNavigationSidebar.m
//  NavigationSidebar
//
//  Created by Sergey Pronin on 02/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSNavigationSidebar.h"
#import <QuartzCore/QuartzCore.h>

@interface PSNavigationSidebar()
-(void)pan:(UIPanGestureRecognizer *)recognizer;
- (IBAction)clickHide:(id)sender;
@end

@implementation PSNavigationSidebar
@synthesize viewControllers;

+(PSNavigationSidebar *)sharedNavigationSideBar {
    static dispatch_once_t once;
    static PSNavigationSidebar *instance;
    dispatch_once(&once, ^{ instance = [[self alloc] init]; });
    return instance;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 460) style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tableView];
    [self.view addSubview:contentView];
    
    
    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [contentView addGestureRecognizer:recognizer];
    [recognizer release];
    
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickHide:)];
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.cancelsTouchesInView = YES;
    [contentView addGestureRecognizer:tapRecognizer];
    
    
    contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    contentView.layer.shadowOffset = CGSizeMake(-3, 0);
    contentView.layer.shadowOpacity = 0.8f;
    contentView.layer.shadowRadius = 2;
}


- (void)viewDidUnload
{
    [tableView release];
    tableView = nil;
    [contentView release];
    contentView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [tableView reloadData];
    if ([viewControllers count] > 0) {
        NSIndexPath *zeroObj = [NSIndexPath indexPathForRow:0 inSection:0];
        [tableView selectRowAtIndexPath:zeroObj animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        [self tableView:tableView didSelectRowAtIndexPath:zeroObj];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc {
    [tableView release];
    [tapRecognizer release];
    [contentView release];
    [viewControllers release];
    
    [super dealloc];
}


#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [viewControllers count];
}

-(UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"CELL"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"];
    }
    
    cell.textLabel.text = [[viewControllers objectAtIndex:indexPath.row] title];
    
    return cell;
}

#pragma mark - UITableViewDataSource

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *controller = [viewControllers objectAtIndex:indexPath.row];
    
    [viewControllers enumerateObjectsUsingBlock:^(id obj, uint idx, BOOL *stop) {
        if ([contentView.subviews containsObject:[obj view]]) {
            [[obj view] removeFromSuperview];
            [obj viewDidDisappear:NO];
        }
    }];
    
    [controller viewWillAppear:NO];
    
    CGRect frame = controller.view.frame;
    frame.origin.y=0;
    controller.view.frame = frame;
    
    [contentView addSubview:controller.view];
    
    [self hideNavigationSideBar];
}

#pragma mark -

-(void)showNavigationSideBar {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SidebarWillShow" object:nil];
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect rect = contentView.frame;
        rect.origin.x = 265;
        contentView.frame = rect;
    } completion:^(BOOL b){
        tapRecognizer.enabled = YES;
    }];
}

-(void)hideNavigationSideBar {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SidebarWillHide" object:nil];
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect rect = contentView.frame;
        rect.origin.x = 0;
        contentView.frame = rect;
    } completion:^(BOOL b){
        tapRecognizer.enabled = NO;
    }];
}

- (IBAction)clickHide:(id)sender {
    [self hideNavigationSideBar];
}

static inline int sign(float x) {
    return x > 0 ? 1 : x < 0 ? -1 : 0;
}

-(void)pan:(UIPanGestureRecognizer *)recognizer {
    float xsw = [recognizer locationInView:self.view].x;
    float calcx = xsw-startx;
    
    float velocity = [recognizer velocityInView:contentView].x;
    __block CGRect rect;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            startx = [recognizer locationInView:contentView].x;
            break;
        case UIGestureRecognizerStateEnded:
            if (abs(velocity) > 500) {
                [recognizer setEnabled:NO];
            }
        case UIGestureRecognizerStateCancelled:
            
            [UIView animateWithDuration:0.2f animations:^{
                rect = contentView.frame;
                if (velocity > 500) { 
                    rect.origin.x = 265;
                } else if (velocity < -500) {
                    rect.origin.x = 0;
                } else {
                    rect.origin.x = sign(floorf(rect.origin.x / 150.f)) * 265;
                }
                contentView.frame = rect;
            } completion:^(BOOL b){
                [recognizer setEnabled:YES];
                if (rect.origin.x < 100) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SidebarWillHide" object:nil];
                    tapRecognizer.enabled = NO;
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SidebarWillShow" object:nil];
                    tapRecognizer.enabled = YES;
                }
            }];
            break;
        default:
            if (calcx < 0 || calcx > 265) { 
                [recognizer setEnabled:NO];
                return;
            }
            
            CGRect rect = contentView.frame;
            rect.origin.x = calcx;
            contentView.frame = rect;
            break;
    }
}

@end 