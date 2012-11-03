//
//  KRedis.m
//  TestTransform
//
//  Created by Liu Xiangchao on 10/16/12.
//
//

#import "KRedis.h"
#import "kitchen_util.h"

#ifdef KITCHEN_REDIS_ENABLED

@implementation KRedis

+ (id) redisWithHost:(NSString *) host port:(int) port {
    id redis = [[self alloc] initWithHost:host port:port];
    return redis;
}

- (BOOL) connect {
    _context = redisConnect([_host UTF8String], _port);
    return (_context->err == 0);
}

- (id) initWithHost:(NSString *) host port:(int) port {
    if (self = [super init]) {
        _host = host;
        _port = port;
        _context = NULL;
    }
    return self;
}

- (BOOL) isValid {
    if (_context == NULL) {
		return [self connect];
	}
    if (!(_context->flags & REDIS_CONNECTED)) {
		redisFree(_context);
		return [self connect];
	}
    if (_context->err != 0) {
		redisFree(_context);
		return [self connect];
	}
	return YES;
}

- (KRedisReply *) command:(NSString *) command {
    if (![self isValid]) {
        return nil;
    }
	redisReply *response = redisCommand(_context, [command UTF8String]);
	KRedisReply *reply = [[KRedisReply alloc] initWithReply:response];
    return reply;
}

- (BOOL) ping {
    KRedisReply *reply = [self command:@"PING"];
    return (reply.type == KRedisReplyTypeStatus && [reply.statusValue isEqualToString:@"PONG"]);
}

- (BOOL) auth:(NSString *) password {
    KRedisReply *reply = [self command:[NSString stringWithFormat:@"AUTH %@", password]];
    return (!reply.hasErrors);
}

- (int) publish:(NSString *) channel message:(NSString *) message {
    KRedisReply *reply = [self command:[NSString stringWithFormat:@"PUBLISH %@ %@", channel, message]];
    if (reply.type == KRedisReplyTypeInteger) {
        return reply.intValue;
    }
    if (reply.hasErrors) {
        KLog(@"error:%@", reply.errorMessage);
    }
    return 0;
}

- (void) subscribe:(NSArray *) channels delegate:(id <KRedisSubscribeDelegate>) delegate {
    _subscribeDelegate = delegate;
    
    [NSThread detachNewThreadSelector:@selector(subscribeInBackground:) toTarget:self withObject:channels];
}

- (void) subscribeInBackground:(NSArray *) channels {
    KRedisReply *reply = [self command:[NSString stringWithFormat:@"SUBSCRIBE %@", [channels componentsJoinedByString:@" "]]];
    if (reply.hasErrors) {
        return;
    }
    while (true) {
        NSArray *replies = [self receive];
        for (KRedisReply *singleReply in replies) {
            if (singleReply.type != KRedisReplyTypeArray) {
                continue;
            }
            NSArray *replyArray = singleReply.arrayValue;
            if (replyArray.count < 3) {
                continue;
            }
            KRedisReply *typeReply = [replyArray objectAtIndex:0];
            if (typeReply.type != KRedisReplyTypeString) {
                continue;
            }
            if (![typeReply.stringValue isEqualToString:@"message"]) {
                continue;
            }
            KRedisReply *channelReply = [replyArray objectAtIndex:1];
            KRedisReply *messageReply = [replyArray objectAtIndex:2];
            if (channelReply.type != KRedisReplyTypeString || messageReply.type != KRedisReplyTypeString) {
                continue;
            }
            if (_subscribeDelegate != nil && [_subscribeDelegate respondsToSelector:@selector(redisSubscribeDidReplyChannel:messsage:)]) {
                [_subscribeDelegate redisSubscribeDidReplyChannel:channelReply.stringValue messsage:messageReply.stringValue];
            }
        }
    }
}

- (NSArray *) receive {
    void * aux = NULL;
	NSMutableArray * replies = [[NSMutableArray alloc] init];
	
    if (![self isValid]) {
        return replies;
    }
    
	if (redisGetReply(_context, &aux) == REDIS_ERR) {
        return replies;
    }
	if (aux == NULL) {
		int wdone = 0;
		while (!wdone) { /* Write until done */
			if (redisBufferWrite(_context, &wdone) == REDIS_ERR) {
				return replies;
			}
		}
        
		while(redisGetReply(_context, &aux) == REDIS_OK) { // get reply
			redisReply *reply = (redisReply *) aux;
            KRedisReply *newReply = [[KRedisReply alloc] initWithReply:reply];
			[replies addObject:newReply];
		}
	} else {
		redisReply * reply = (redisReply*)aux;
		KRedisReply *newReply = [[KRedisReply alloc] initWithReply:reply];
        [replies addObject:newReply];
	}
	
    return replies;
}

- (void) close {
    redisFree(_context);
	_context = NULL;
}

@end

@implementation KRedisReply

- (id) initWithReply:(redisReply *) reply {
    if (self = [super init]) {
        _reply = reply;
    }
    return self;
}

- (KRedisReplyType) type {
    return _reply->type;
}

- (BOOL) hasErrors {
    return (_reply->type == KRedisReplyTypeError);
}

- (NSString *) errorMessage {
    if (_reply->type == KRedisReplyTypeError) {
        return [NSString stringWithUTF8String:_reply->str];
    }
    return nil;
}

- (NSString *) stringValue {
    if (_reply->type == KRedisReplyTypeString) {
        return [NSString stringWithUTF8String:_reply->str];
    }
    return nil;
}

- (NSArray *) arrayValue {
    if (_reply->type == KRedisReplyTypeArray) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int i = 0; i < _reply->elements; i ++) {
            redisReply *element = _reply->element[i];
            KRedisReply *newReply = [[KRedisReply alloc] initWithReply:element];
            [array addObject:newReply];
        }
        return array;
    }
    return nil;
}

- (int) intValue {
    if (_reply->type == KRedisReplyTypeInteger) {
        return _reply->integer;
    }
    return 0;
}

- (NSString *) statusValue {
    if (_reply->type == KRedisReplyTypeStatus) {
        return [NSString stringWithUTF8String:_reply->str];
    }
    return nil;
}

- (void) free {
    freeReplyObject(_reply);
}

- (void) dealloc {
    [self free];
}

@end

#endif

