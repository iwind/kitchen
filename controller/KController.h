//
//  KController.h
//  testnavigation2
//
//  Created by LiuXiangChao on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KController : UIViewController {
@private
    UIView *_lastView;//上一次插入的视图
    NSMutableDictionary *_params;
    BOOL _isFirstDisplay;
}

/** 视图切换 **/
- (void) switchViewTo: (KController *) viewController;

/** 传递的参数集 **/
- (void) setParams:(NSMutableDictionary *) params;
- (void) setParam:(id) value forKey:(NSString *) key;
- (NSMutableDictionary *) params;
- (id) param:(NSString *) path;
- (int) paramInt:(NSString *) path;

/** 其他 **/
- (BOOL) isFirstDisplay;

@end
