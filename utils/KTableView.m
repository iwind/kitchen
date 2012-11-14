//
//  KTableView.m
//  TestTransform
//
//  Created by Liu Xiangchao on 11/9/12.
//
//

#import "KTableView.h"
#import "KExtension.h"

@implementation KTableView

@synthesize pullingChanged;

- (void) setPullingView:(UIView <KTableViewPullingDelegate> *) pullingView {
    if (_pullingView) {
        [_pullingView removeFromSuperview];
    }
    _pullingView = pullingView;
    [self insertSubview:_pullingView atIndex:0];
    [_pullingView setPosition:CGPointMake(_pullingView.frame.origin.x, -_pullingView.frame.size.height)];
    
    if ([_pullingView respondsToSelector:@selector(onPullingBeforeRelease:)]) {
        [_pullingView onPullingBeforeRelease:self];
    }
    
    _pullingState = KTableViewPullingStateBefore;
}

- (void) setPullingTarget:(id) target selector:(SEL) selector {
    _pullingTarget = target;
    _pullingSelector = selector;
}

- (void) pullingScrolling {
    if (self.dragging) {
        if (self.contentOffset.y < -_pullingView.frame.size.height) {
            if (_pullingState != KTableViewPullingStateWill) {
                _pullingState = KTableViewPullingStateWill;
                [_pullingView removeAllSubviews];
                [_pullingView onPullingWillRelease:self];
            }
        }
        else {
            if (_pullingState != KTableViewPullingStateBefore) {
                _pullingState = KTableViewPullingStateBefore;
                [_pullingView removeAllSubviews];
                [_pullingView onPullingBeforeRelease:self];
            }
        }
    }
}

- (void) pullingScrollEnd {
    BOOL willUpdate = (_pullingState == KTableViewPullingStateWill);
    if (!willUpdate){
        return;
    }
    if (_pullingState != KTableViewPullingStateDid) {
        _pullingState = KTableViewPullingStateDid;
        [self setContentInset:UIEdgeInsetsMake(_pullingView.frame.size.height, 0.0, 0.0, 0.0)];
        [_pullingView removeAllSubviews];
        [_pullingView onPullingDidRelease:self];
        
        //调用Updating
        if (_pullingTarget != nil && [_pullingTarget respondsToSelector:_pullingSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [_pullingTarget performSelector:_pullingSelector withObject:self];
#pragma clang diagnostic pop
        }
        else {
            [self pullingEnd];
        }
    }
}

- (void) pullingEnd {
    [self setContentInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [_pullingView onPullingDidUpdate:self];
}

@end