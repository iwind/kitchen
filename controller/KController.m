//
//  KController.m
//  testnavigation2
//
//  Created by LiuXiangChao on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KController.h"
#import "KNavigationController.h"
#import "KExtension.h"

@interface KController ()

@end

@implementation KController

/** switch to another view **/


- (void) switchViewTo: (KController *) viewController {
    if (_lastView) {
        [_lastView removeFromSuperview];
    }
    _lastView = viewController.view;
    [self.view insertSubview:_lastView atIndex:0];
}

#pragma mark Events


/** set params to be displayed **/
- (void) setParams:(NSMutableDictionary *) params {
    _params = params;
}

- (void) setParam:(id) value forKey:(NSString *) key {
    _params = [self params];
    [_params setObject:value forKey:key];
}

/** read params to be displayed **/
- (NSMutableDictionary *) params {
    if (!_params) {
        _params = [[NSMutableDictionary alloc] init];
    }
    return _params;
}

/** read params for a path **/
- (id) param:(NSString *) path {
    if (!_params) {
        return nil;
    }
    return [_params objectForPath:path];
}

- (int) paramInt:(NSString *) path {
    NSObject *value = [self param:path];
    if (value == nil) {
        return 0;
    }
    if ([value respondsToSelector:@selector(intValue)]) {
        return (int)[value performSelector:@selector(intValue)];
    }
    return 0;
}

/** 其他 **/
- (BOOL) isFirstDisplay {
    return _isFirstDisplay;
}

#pragma mark Inherited methods
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
    _isFirstDisplay = NO;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    _isFirstDisplay = YES;
    [self onInit];
}


#pragma mark Old methods

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
