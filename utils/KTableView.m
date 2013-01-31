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

- (void) setHeaderPullingView:(UIView <KTableViewPullingDelegate> *) pullingView {
    if (_headerPullingView) {
        [_headerPullingView removeFromSuperview];
    }
    _headerPullingView = pullingView;
    [self insertSubview:_headerPullingView atIndex:0];
    [_headerPullingView setPosition:CGPointMake(_headerPullingView.frame.origin.x, -_headerPullingView.frame.size.height)];
    
    if ([_headerPullingView respondsToSelector:@selector(tableViewPullingHeaderBeforeRelease::)]) {
        [_headerPullingView tableViewPullingHeaderBeforeRelease:self];
    }
    
    _pullingState = KTableViewPullingStateBefore;
}

- (void) setHeaderPullingTarget:(id) target selector:(SEL) selector {
    _headerPullingTarget = target;
    _headerPullingSelector = selector;
}

- (void) pullingScrolling {
    if (self.dragging) {
        if (self.contentOffset.y < -_headerPullingView.frame.size.height) {
            if (_pullingState != KTableViewPullingStateWill) {
                _pullingState = KTableViewPullingStateWill;
                [_headerPullingView removeAllSubviews];
                
                if ([_headerPullingView respondsToSelector:@selector(tableViewPullingHeaderWillRelease:)]) {
                    [_headerPullingView tableViewPullingHeaderWillRelease:self];
                }
            }
        }
        else {
            if (_pullingState != KTableViewPullingStateBefore) {
                _pullingState = KTableViewPullingStateBefore;
                [_headerPullingView removeAllSubviews];
                
                if ([_headerPullingView respondsToSelector:@selector(tableViewPullingHeaderBeforeRelease:)]) {
                    [_headerPullingView tableViewPullingHeaderBeforeRelease:self];
                }
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
        [self setContentInset:UIEdgeInsetsMake(_headerPullingView.frame.size.height, 0.0, 0.0, 0.0)];
        [_headerPullingView removeAllSubviews];
        
        if ([_headerPullingView respondsToSelector:@selector(tableViewPullingHeaderDidRelease:)]) {
            [_headerPullingView tableViewPullingHeaderDidRelease:self];
        }
        
        //调用Updating
        if (_headerPullingTarget != nil && [_headerPullingTarget respondsToSelector:_headerPullingSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [_headerPullingTarget performSelector:_headerPullingSelector withObject:self];
#pragma clang diagnostic pop
        }
        else {
            [self pullingEnd];
        }
    }
}

- (void) pullingEnd {
    [self setContentInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    
    if ([_headerPullingView respondsToSelector:@selector(tableViewPullingHeaderDidUpdate:)]) {
        [_headerPullingView tableViewPullingHeaderDidUpdate:self];
    }
}

@end