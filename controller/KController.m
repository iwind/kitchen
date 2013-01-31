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
#import "KApp.h"

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

- (BOOL) isFirstUserDisplay {
    return _isFirstUserDisplay;
}

/** 提示框 **/
- (void) confirm:(NSString *) message callback:(void (^)(BOOL confirmed)) callback {
    _confirmCallback = callback;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"系统提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.tag = 880001;
    [alertView show];
}

- (void) alert:(NSString *) message callback:(void (^)()) callback {
    _alertCallback = callback;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"系统提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    alertView.tag = 880002;
    [alertView show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 880001) {
        if (buttonIndex == 0) {
            if (_confirmCallback) {
                _confirmCallback(NO);
            }
        }
        else if (buttonIndex == 1) {
            if (_confirmCallback) {
                _confirmCallback(YES);
            }
        }
    }
    else if (alertView.tag == 880002) {
        if (_alertCallback) {
            _alertCallback();
        }
    }
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
    _isFirstUserDisplay = NO;
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
    _isFirstUserDisplay = YES;
    [self onInit];
    
    //用户账户改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doUserChangeDisplay:) name:KAppUserChangedNotification object:nil];
}

- (void) doUserChangeDisplay:(NSNotification *) notification {
    _isFirstUserDisplay = YES;
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
