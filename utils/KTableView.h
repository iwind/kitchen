//
//  KTableView.h
//  TestTransform
//
//  Created by Liu Xiangchao on 11/9/12.
//
//

#import <Foundation/Foundation.h>

@class KTableView;

typedef enum {
    KTableViewPullingStateBefore,
    KTableViewPullingStateWill,
    KTableViewPullingStateDid
} KTableViewPullingState;

@protocol KTableViewPullingDelegate <NSObject>

- (void) onPullingBeforeRelease:(KTableView *) tableView;
- (void) onPullingWillRelease:(KTableView *) tableView;
- (void) onPullingDidRelease:(KTableView *) tableView;
- (void) onPullingDidUpdate:(KTableView *) tableView;

@end

@interface KTableView : UITableView {
@private
    UIView <KTableViewPullingDelegate> *_pullingView;
    id _pullingTarget;
    SEL _pullingSelector;
    
    KTableViewPullingState _pullingState;
}

@property (nonatomic) BOOL pullingChanged;

- (void) setPullingView:(UIView <KTableViewPullingDelegate> *) pullingView;
- (void) setPullingTarget:(id) target selector:(SEL) selector;
- (void) pullingScrolling;
- (void) pullingScrollEnd;
- (void) pullingEnd;

@end