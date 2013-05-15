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

- (void) removeParam:(NSString *) key {
    [_params removeObjectForKey:key];
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

/** 键盘 **/
- (void) keyboardShow:(NSNotification *) notice {
    CGRect rect = [[notice.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        _keyboardHeight = rect.size.height;
    }
    else {
        _keyboardHeight = rect.size.width;
    }
    [self onKeyboardShow:_keyboardHeight];
    
}

- (void) keyboardHide:(NSNotification *) notice {
    _keyboardHeight = 0.0;
    [self onKeyboardHide];
}

- (float) keyboardHeight {
    return _keyboardHeight;
}

- (void) adjustViewForKeyboard:(UIView *) inputView {
    CGPoint location = [self.view convertPoint:CGPointMake(0.0, 0.0) fromView:inputView];
    float diff = location.y + inputView.frame.size.height + _keyboardHeight - self.view.frame.size.height;
    if (diff > 0) {
        [UIView animateWithDuration:0.2 animations:^{
            [self.view setPosition:CGPointMake(0.0, -diff)];
        }];
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
    
    //键盘事件
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self onUnload];
    _isFirstDisplay = NO;
    _isFirstUserDisplay = NO;
    
    //键盘事件
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
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

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
