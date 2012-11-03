//
//  KMetroContainer.m
//  TestTransform
//
//  Created by LiuXiangChao on 9/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KMetroContainer.h"

@implementation KMetroContainer

- (id) init {
    if (self = [super init]) {
        
    }
    return self;
}

- (id) initWithFrame:(CGRect) _frame background:(UIImage *) backgroundImage backgroundSize:(CGSize) size {
    if (self = [self init]) {
        self.frame = _frame;
        
        _backgroundView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, _frame.size.width, _frame.size.height)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
        imageView.image = backgroundImage;
        [_backgroundView setShowsVerticalScrollIndicator:NO];
        [_backgroundView setShowsHorizontalScrollIndicator:NO];
        [_backgroundView addSubview:imageView];
        
        _controllerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, _frame.size.width, _frame.size.height)];
        [_controllerView setPagingEnabled:YES];
        [_controllerView setBackgroundColor:[UIColor clearColor]];
        [_controllerView setShowsVerticalScrollIndicator:NO];
        [_controllerView setShowsHorizontalScrollIndicator:NO];
        [_controllerView setDelegate:self];
        
        [self addSubview:_backgroundView];
        [self addSubview:_controllerView];
    }
    
    return self;
}

- (int) visibleIndex {
    for (int i = 0; i < _controllerView.subviews.count; i ++) {
        UIView *subview = [_controllerView.subviews objectAtIndex:i];
        if (subview.frame.origin.x >= _controllerView.contentOffset.x) {
            return i;
        }
    }
    return -1;
}

- (void) pushController:(UIViewController *) controller {
    [_controllerView append:controller.view];
    [_controllerView setContentSize:CGSizeMake(controller.view.frame.origin.x + controller.view.frame.size.width, _controllerView.frame.size.height)];
    
    [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [_controllerView setContentOffset:CGPointMake(controller.view.frame.origin.x, 0.0) animated:NO];
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void) popController {
    int index = [self visibleIndex];
    
    if (index <= 0) {
        return;
    }
    
    UIView *currentView = [_controllerView.subviews objectAtIndex:index];
    index --;
    UIView *nextView = [_controllerView.subviews objectAtIndex:index];
    
    [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionCurveEaseOut  animations:^(void) {
        [_controllerView setContentOffset:CGPointMake(nextView.frame.origin.x, 0.0) animated:NO];
        
    } completion:^(BOOL finished) {
        [currentView remove];
        
        [_controllerView setContentSize:CGSizeMake(nextView.frame.origin.x + nextView.frame.size.width, _controllerView.frame.size.height)];
    }];
}

- (void) backcontroller {
    int index = [self visibleIndex];
    if (index <= 0) {
        return;
    }
    
    index --;
    UIView *nextView = [_controllerView.subviews objectAtIndex:index];
    
    [UIView animateWithDuration:0.35 delay:0.0 options:UIViewAnimationOptionCurveEaseOut  animations:^(void) {
        [_controllerView setContentOffset:CGPointMake(nextView.frame.origin.x, 0.0) animated:NO];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [_backgroundView setContentOffset:CGPointMake(scrollView.contentOffset.x/3.0, scrollView.contentOffset.y) animated:NO];
}

- (UIScrollView *) contentView {
    return _controllerView;
}


@end
