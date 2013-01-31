//
//  KSyncService.h
//  Track
//
//  Created by Liu Xiangchao on 10/19/12.
//
//

#import <Foundation/Foundation.h>

@class KSyncHandler;
@protocol KSyncServiceDelegate;

@interface KSyncService : NSObject {
@private
    NSMutableDictionary *_handlers;
    BOOL _isUpdating;
    BOOL _isCommitting;
    NSMutableDictionary *_requestParams;
}

@property (nonatomic) NSObject <KSyncServiceDelegate> *delegate;

+ (id) defaultService;

- (void) registerHandler:(KSyncHandler *) handler for:(NSString *) dataType;
- (void) update;
- (void) exec:(NSArray *) updates;
- (NSArray *) collect;
- (void) commit;

- (int) version;
- (int) updatedAt;

- (void) addParam:(NSString *) param forKey:(NSString *) key;

@end

@protocol KSyncServiceDelegate <NSObject>

@optional
- (BOOL) syncServiceShouldUpdate:(KSyncService *) syncService;
- (BOOL) syncServiceShouldCommit:(KSyncService *) syncService;
- (void) syncServiceWillExecUpdates:(KSyncService *) syncService;
- (void) syncServiceDidUpdate:(KSyncService *) syncService;
- (void) syncServiceDidCommit:(KSyncService *) syncService;

@end
