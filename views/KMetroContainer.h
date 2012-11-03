//
//  KMetroContainer.h
//  TestTransform
//
//  Created by LiuXiangChao on 9/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KViewStyle.h"

@interface KMetroContainer : UIView <UIScrollViewDelegate> {
@private
    UIScrollView *_backgroundView;
    UIScrollView *_controllerView;
}

- (id) initWithFrame:(CGRect) frame background:(UIImage *) backgroundImage backgroundSize:(CGSize) size;
- (int) visibleIndex;
- (void) pushController:(UIViewController *) controller;
- (void) popController;
- (void) backcontroller;
- (UIScrollView *) contentView;

@end
