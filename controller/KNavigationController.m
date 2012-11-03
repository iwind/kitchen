//
//  KNavigationController.m
//  testnavigation2
//
//  Created by LiuXiangChao on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KNavigationController.h"
#import "RootController.h"
#import "KExtension.h"

@interface KNavigationController ()

@end

static KNavigationController *defaultController;

@implementation KNavigationController

+ (void) setupInWindow:(UIWindow *) window {
    RootController *rootController = [[RootController alloc] initWithNibName:@"RootController" bundle:nil];
    defaultController = [[KNavigationController alloc] initWithRootViewController:rootController];
    
    window.rootViewController = defaultController;
}

+ (KNavigationController *) defaultController {
    return defaultController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self onInit];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self onBefore];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self onLoad];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self onUnload];
}

#pragma mark -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
