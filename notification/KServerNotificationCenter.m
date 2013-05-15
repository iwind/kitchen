//
//  KServerNotificationCenter.m
//  Track
//
//  Created by Liu Xiangchao on 10/28/12.
//
//

#import "KServerNotificationCenter.h"
#import "KApiRequest.h"
#import "kitchen.h"

@implementation KServerNotificationCenter

@synthesize delegate;

+ (id) defaultCenter {
    static id instance = nil;
    if (instance == nil) {
        instance = [[self alloc] init];
    }
    return instance;
}

- (id) init {
    if (self = [super init]) {
        _params = [NSMutableDictionary dictionary];
        _handlers = [NSMutableDictionary dictionary];
        _isStarted = NO;
        _ttl = 10.0;
    }
    return self;
}

- (void) setTtl:(int) ttl {
    _ttl = ttl;
}

- (void) addParam:(NSString *) param forKey:(NSString *) key {
    [_params setObject:param forKey:key];
}

- (void) registerHandler:(KServerNotificationHandler *) handler for:(int) templateId {
    [_handlers setObject:handler forKey:[NSNumber numberWithInt:templateId]];
}

- (void) registerDefaultHandler:(KServerNotificationHandler *) handler {
    _defaultHandler = handler;
}

- (void) start {
    if (_isStarted) {
        return;
    }
    _isStarted = YES;
    [self performSelectorInBackground:@selector(startInBackground) withObject:nil];
}

- (void) startInBackground {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(serverNotificationCenterShouldUpdate:)]) {
        if (![self.delegate serverNotificationCenterShouldUpdate:self]) {
            [NSThread sleepForTimeInterval:_ttl];
            [self startInBackground];
            return;
        }
    }
    [NSThread sleepForTimeInterval:_ttl];
    
    //查询最后一条
    NSString *updateURL = [[KApp defaultApp] option:@"notification.retrieve"];
    KApiRequest *req = [[KApiRequest alloc] initWithURLString:updateURL];
    for (NSString *key in _params) {
        [req setPostValue:[_params objectForKey:key] forKey:key];
    }
    KApiRequest *blockReq = req;
    [req setCompletionBlock:^{
        KApiResponse *response = blockReq.responseApi;
        if (response.code == 200) {
            NSDictionary *info = response.data;
            int templateId = [info intForPath:@"template_id"];
            
            //是否有处理器
            KServerNotificationHandler *handler = [_handlers objectForKey:[NSNumber numberWithInt:templateId]];
            if (handler == nil) {
                handler = _defaultHandler;
            }
            if (handler != nil) {
                KServerNotification *notice = [[KServerNotification alloc] init];
                [notice setSenderId:[info intForPath:@"rock_uid"]];
                [notice setUserId:[info intForPath:@"user_id"]];
                [notice setBody:[info stringForPath:@"body"]];
                [notice setTemplateId:templateId];
                
                id params = [info objectForKey:@"params"];
                if (params != nil && [params isKindOfClass:[NSDictionary class]]) {
                    [notice setParams:params];
                }
                
                [notice setCreatedAt:[info intForPath:@"created_at"]];
                
                [handler performSelectorOnMainThread:@selector(handle:) withObject:notice waitUntilDone:YES];
            }
        }
        
        //下一轮更新
        [self performSelectorInBackground:@selector(startInBackground) withObject:nil];
    }];
    [req setFailedBlock:^{
        //下一轮更新
        [self performSelectorInBackground:@selector(startInBackground) withObject:nil];
    }];
    [req startAsynchronous];
}

@end
