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
@protocol KRedisDelegate;

@interface KRedis : NSObject {
@private
    redisContext * _context;
	NSString *_host;
	int _port;
    NSString *_password;
    NSTimeInterval _timeout;
}

@property (nonatomic, retain) NSObject <KRedisDelegate> *delegate;

+ (id) redisWithHost:(NSString *) host port:(int) port;

- (void) setTimeout:(NSTimeInterval) timeout;
- (void) setPassword:(NSString *) password;
- (BOOL) connect;

- (BOOL) isValid;

- (KRedisReply *) command:(NSString *) command;

- (BOOL) ping;
- (int) publish:(NSString *) channel message:(NSString *) message;
- (void) subscribe:(NSArray *) channels;

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

@protocol KRedisDelegate <NSObject>

@optional
- (void) redisDidConnect:(KRedis *) redis;
- (void) redisDidDisconnect:(KRedis *) redis;
- (void) redisSubscribeDidReply:(KRedis *) redis channel:(NSString *) channel messsage:(NSString *) message;

@end

#endif
