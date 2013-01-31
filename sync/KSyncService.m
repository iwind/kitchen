//
//  KSyncService.m
//  Track
//
//  Created by Liu Xiangchao on 10/19/12.
//
//

#import "KSyncService.h"
#import "KSyncUpdate.h"
#import "NSObject+SBJSON.h"
#import "kitchen.h"
#import "KSyncHandler.h"

@implementation KSyncService

@synthesize delegate;

+ (id) defaultService {
    static id instance = nil;
    if (instance == nil) {
        instance = [[self alloc] init];
    }
    return instance;
}

- (id) init {
    if (self = [super init]) {
        _handlers = [NSMutableDictionary dictionary];
        _isUpdating = NO;
        _isCommitting = NO;
        _requestParams = [NSMutableDictionary dictionary];
    }
    return self;
}

/** 注册处理句柄 **/
- (void) registerHandler:(KSyncHandler *) handler for:(NSString *) dataType {
    [_handlers setObject:handler forKey:dataType];
}

/** 从服务器获得更新 **/
- (void) update {
    if (_isUpdating || _isCommitting) {
        
        //调用Delegate
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(syncServiceDidUpdate:)]) {
            [self.delegate syncServiceDidUpdate:self];
        }
        
        return;
    }
    _isUpdating = YES;

    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(syncServiceShouldUpdate:)]) {
        if (![self.delegate syncServiceShouldUpdate:self]) {
            _isUpdating = NO;
            
            //调用Delegate
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(syncServiceDidUpdate:)]) {
                [self.delegate syncServiceDidUpdate:self];
            }
            
            return;
        }
    }
    
    NSString *apiURL = [[KApp defaultApp] option:@"sync.updates"];
    KApiRequest *req = [[KApiRequest alloc] initWithURLString:apiURL];
    for (NSString *requestParamName in _requestParams) {
        [req setPostValue:[_requestParams objectForKey:requestParamName] forKey:requestParamName];
    }
    [req setPostInt:[self version] forKey:@"version"];
    KApiRequest *blockReq = req;
    [req setCompletionBlock:^{
        KApiResponse *response = blockReq.responseApi;
        
        if (response.code == SUCCESS) {
            //执行
            NSArray *updates = [response data:@"updates"];
            NSMutableArray *updatesArray = [[NSMutableArray alloc] init];
            for (NSDictionary *updateDictionary in updates) {
                KSyncUpdate *update = [[KSyncUpdate alloc] initWithDictionary:updateDictionary];
                [updatesArray addObject:update];
            }
            [self exec:updatesArray];
            
            //更新版本
            KSettings *settings = [KSettings defaultSettings];
            NSNumber *versionNumber = [response data:@"version"];
            [settings updateValue:[versionNumber stringValue] forKey:@"sync_version"];
            [settings updateValue:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]] forKey:@"sync_updated_at"];
        }
        else {
            KLog(@"KSynService failed to updating, response code:%d", response.code);
        }
        
        _isUpdating = NO;
        
        //调用Delegate
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(syncServiceDidUpdate:)]) {
            [self.delegate performSelectorInBackground:@selector(syncServiceDidUpdate:) withObject:self];
        }
    }];
    [req setFailedBlock:^{
        _isUpdating = NO;
        
        //调用Delegate
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(syncServiceDidUpdate:)]) {
            [self.delegate performSelectorInBackground:@selector(syncServiceDidUpdate:) withObject:self];
        }
    }];
    [req startAsynchronous];
    req = nil;
}

/** 执行服务器上的更新 **/
- (void) exec:(NSArray *) updates {
    if (updates.count == 0) {
        return;
    }
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(syncServiceWillExecUpdates:)]) {
        [self.delegate performSelectorInBackground:@selector(syncServiceWillExecUpdates:) withObject:self];
    }
    
    for (KSyncUpdate *update in updates) {
        KSyncHandler *handler = [_handlers objectForKey:update.dataType];
        if (handler == nil) {
            continue;
        }
        SEL method = NSSelectorFromString([NSString stringWithFormat:@"do%@:", [update.action capitalizedString]]);
        if ([handler respondsToSelector:method]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [handler performSelector:method withObject:update];
#pragma clang diagnostic pop
        }
    }
}

/** 收集本地更新 **/
- (NSArray *) collect {
    NSMutableArray *updates = [NSMutableArray array];
    for (NSString *handlerName in _handlers) {
        KSyncHandler *handler = [_handlers objectForKey:handlerName];
        [updates addObjectsFromArray:[handler collect]];
    }
    return updates;
}

/** 提交本地更新到服务器 **/
- (void) commit {
    if (_isUpdating || _isCommitting) {
        return;
    }
    _isCommitting = YES;
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(syncServiceShouldUpdate:)]) {
        if (![self.delegate syncServiceShouldCommit:self]) {
            _isCommitting = NO;
            
            //调用Delegate
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(syncServiceDidCommit:)]) {
                [self.delegate syncServiceDidCommit:self];
            }
            
            return;
        }
    }
    
    NSArray *updates = [self collect];
    if (updates.count == 0) {
        _isCommitting = NO;
        
        //调用Delegate
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(syncServiceDidCommit:)]) {
            [self.delegate syncServiceDidCommit:self];
        }
        
        return;
    }
    NSMutableArray *updateObjects = [NSMutableArray array];
    for (KSyncUpdate *update in updates) {
        [updateObjects addObject:[update asDictionary]];
    }
    NSString *json = [updateObjects JSONFragment];
    
    //发送数据
    NSString *apiURL = [[KApp defaultApp] option:@"sync.commit"];
    KApiRequest *req = [[KApiRequest alloc] initWithURLString:apiURL];
    for (NSString *requestParamName in _requestParams) {
        [req setPostValue:[_requestParams objectForKey:requestParamName] forKey:requestParamName];
    }
    [req setPostInt:[self version] forKey:@"version"];
    [req setPostValue:json forKey:@"updates"];
    KApiRequest *blockReq = req;
    [req setCompletionBlock:^{
        //更新版本
        if (blockReq.responseApi.code == SUCCESS) {
            KSettings *settings = [KSettings defaultSettings];
            NSNumber *versionNumber = [blockReq.responseApi data:@"version"];
            [settings updateValue:[versionNumber stringValue] forKey:@"sync_version"];
            [settings updateValue:[NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]] forKey:@"sync_committed_at"];
            
            int version = [versionNumber intValue];
            for (KSyncUpdate *update in updates) {
                KSyncHandler *handler = [_handlers objectForKey:[update dataType]];
                if (handler == nil) {
                    continue;
                }
                update.version = version;
                SEL method = NSSelectorFromString([NSString stringWithFormat:@"did%@:", [update.action capitalizedString]]);
                if ([handler respondsToSelector:method]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [handler performSelector:method withObject:update];
#pragma clang diagnostic pop
                }
            }
        }
        else {
            KLog(@"KSynService failed to committing, response code:%d", blockReq.responseApi.code);
        }
        
        _isCommitting = NO;
        
        //调用Delegate
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(syncServiceDidCommit:)]) {
            [self.delegate performSelectorInBackground:@selector(syncServiceDidCommit:) withObject:self];
        }
    }];
    [req setFailedBlock:^{
        _isCommitting = NO;
        
        //调用Delegate
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(syncServiceDidCommit:)]) {
            [self.delegate performSelectorInBackground:@selector(syncServiceDidCommit:) withObject:self];
        }
    }];
    
    [req startAsynchronous];
    req = nil;
}

- (int) version {
    KSettings *settings = [KSettings defaultSettings];
    int version = [settings intForKey:@"sync_version"];
    return version;
}

- (int) updatedAt {
    KSettings *settings = [KSettings defaultSettings];
    int updatedAt = [settings intForKey:@"sync_updated_at"];
    return updatedAt;
}

- (void) addParam:(NSString *) param forKey:(NSString *) key {
    [_requestParams setObject:param forKey:key];
}

@end
