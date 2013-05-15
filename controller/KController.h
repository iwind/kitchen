//
//  KController.h
//  testnavigation2
//
//  Created by LiuXiangChao on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KController : UIViewController <UIAlertViewDelegate> {
@private
    UIView *_lastView;//上一次插入的视图
    NSMutableDictionary *_params;
    BOOL _isFirstDisplay;
    BOOL _isFirstUserDisplay;
    
    void (^_confirmCallback) (BOOL isConfirmed);
    void (^_alertCallback)();
    
    float _keyboardHeight;
}

/** 视图切换 **/
- (void) switchViewTo: (KController *) viewController;

/** 传递的参数集 **/
- (void) setParams:(NSMutableDictionary *) params;
- (void) setParam:(id) value forKey:(NSString *) key;
- (NSMutableDictionary *) params;
- (void) removeParam:(NSString *) key;
- (id) param:(NSString *) path;
- (int) paramInt:(NSString *) path;

/** 其他 **/
- (BOOL) isFirstDisplay;
- (BOOL) isFirstUserDisplay;

/** 提示框 **/
- (void) confirm:(NSString *) message callback:(void (^)(BOOL confirmed)) callback;
- (void) alert:(NSString *) message callback:(void (^)()) callback;

/** 键盘 **/
- (float) keyboardHeight;
- (void) adjustViewForKeyboard:(UIView *) inputView;

@end
