//
//  KRedis.h
//  TestTransform
//
//  Created by Liu Xiangchao on 10/16/12.
//
//

#import "kitchen_init.h"

#ifdef KITCHEN_REDIS_ENABLED

#import <Foundation/Foundation.h>
#import "hiredis.h"

@class KRedisReply;
@protocol KRedisSubscribeDelegate;

@interface KRedis : NSObject {
@private
    redisContext * _context;
	NSString *_host;
	int _port;
    
    id <KRedisSubscribeDelegate> _subscribeDelegate;
}

+ (id) redisWithHost:(NSString *) host port:(int) port;

- (BOOL) connect;

- (BOOL) isValid;

- (KRedisReply *) command:(NSString *) command;

- (BOOL) ping;
- (BOOL) auth:(NSString *) password;
- (int) publish:(NSString *) channel message:(NSString *) message;
- (void) subscribe:(NSArray *) channels delegate:(id <KRedisSubscribeDelegate>) delegate;

- (void) close;

@end


typedef enum {
    KRedisReplyTypeString = REDIS_REPLY_STRING,
    KRedisReplyTypeArray = REDIS_REPLY_ARRAY,
    KRedisReplyTypeInteger = REDIS_REPLY_INTEGER,
    KRedisReplyTypeNil = REDIS_REPLY_NIL,
    KRedisReplyTypeStatus = REDIS_REPLY_STATUS,
    KRedisReplyTypeError = REDIS_REPLY_ERROR
} KRedisReplyType;

@interface KRedisReply : NSObject {
@private
    redisReply *_reply;
}

- (id) initWithReply:(redisReply *) reply;

- (KRedisReplyType) type;

- (BOOL) hasErrors;
- (NSString *) errorMessage;

- (NSString *) stringValue;
- (NSArray *) arrayValue;
- (int) intValue;
- (NSString *) statusValue;

- (void) free;

@end

@protocol KRedisSubscribeDelegate <NSObject>

- (void) redisSubscribeDidReplyChannel:(NSString *) channel messsage:(NSString *) message;

@end

#endif
