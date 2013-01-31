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

@optional
- (void) tableViewPullingHeaderBeforeRelease:(KTableView *) tableView;
- (void) tableViewPullingHeaderWillRelease:(KTableView *) tableView;
- (void) tableViewPullingHeaderDidRelease:(KTableView *) tableView;
- (void) tableViewPullingHeaderDidUpdate:(KTableView *) tableView;
- (void) tableViewPullingFooterBeforeRelease:(KTableView *) tableView;
- (void) tableViewPullingFooterWillRelease:(KTableView *) tableView;
- (void) tableViewPullingFooterDidRelease:(KTableView *) tableView;
- (void) tableViewPullingFooterDidUpdate:(KTableView *) tableView;

@end

@interface KTableView : UITableView {
@private
    UIView <KTableViewPullingDelegate> *_headerPullingView;
    id _headerPullingTarget;
    SEL _headerPullingSelector;
    
    KTableViewPullingState _pullingState;
}

@property (nonatomic) BOOL pullingChanged;

- (void) setHeaderPullingView:(UIView <KTableViewPullingDelegate> *) pullingView;
- (void) setHeaderPullingTarget:(id) target selector:(SEL) selector;
- (void) pullingScrolling;
- (void) pullingScrollEnd;
- (void) pullingEnd;

@end