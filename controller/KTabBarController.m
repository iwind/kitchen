//
//  KTabBarController.m
//  testnavigation2
//
//  Created by LiuXiangChao on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KTabBarController.h"
#import "KExtension.h"

@interface KTabBarController ()

@end

@implementation KTabBarController

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

- (void) viewDidLoad {
    [super viewDidLoad];
    [self onInit];
}

@end
