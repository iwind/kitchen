//
//  KRedis.m
//  TestTransform
//
//  Created by Liu Xiangchao on 10/16/12.
//
//

#import "KRedis.h"
#import "kitchen_util.h"
#import "Reachability.h"

#ifdef KITCHEN_REDIS_ENABLED

@implementation KRedis

@synthesize delegate;

+ (id) redisWithHost:(NSString *) host port:(int) port {
    id redis = [[self alloc] initWithHost:host port:port];
    return redis;
}

- (void) setTimeout:(NSTimeInterval) timeout {
    _timeout = timeout;
}

- (void) setPassword:(NSString *) password {
    _password = password;
}

- (BOOL) connect {
    if ([Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable) {
        [NSThread sleepForTimeInterval:10.0];
        [self responseError];
        return NO;
    }
    
    if (_context != NULL) {
        redisFree(_context);
        _context = NULL;
    }
    _context = redisConnect([_host UTF8String], _port);
    BOOL r = (_context->err == 0);
    if (r) {
        if (_timeout > 0.0) {
            struct timeval timeout;
            timeout.tv_sec = (long)_timeout;
            timeout.tv_usec = 0;
            redisSetTimeout(_context, timeout);
        }
        if (_password) {
            [self auth];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(redisDidConnect:)]) {
            [self.delegate redisDidConnect:self];
        }
    }
    else {
        [self responseError];
    }
    return r;
}

- (id) initWithHost:(NSString *) host port:(int) port {
    if (self = [super init]) {
        _host = host;
        _port = port;
        _context = NULL;
        _timeout = 0.0;
        _password = nil;
    }
    return self;
}

- (BOOL) isValid {
    if (_context == NULL) {
		return NO;
	}
    if (!(_context->flags & REDIS_CONNECTED)) {
		redisFree(_context);
        _context = NULL;
		return NO;
	}
    if (_context->err != 0) {
		redisFree(_context);
        _context = NULL;
		return NO;
	}
	return YES;
}

- (KRedisReply *) command:(NSString *) command {
    if (![self isValid]) {
        return nil;
    }
	redisReply *response = redisCommand(_context, [command UTF8String]);
    if (response == NULL) {
        return nil;
    }
	KRedisReply *reply = [[KRedisReply alloc] initWithReply:response];
    return reply;
}

- (BOOL) ping {
    KRedisReply *reply = [self command:@"PING"];
    return (reply.type == KRedisReplyTypeStatus && [reply.statusValue isEqualToString:@"PONG"]);
}

- (BOOL) auth {
    KRedisReply *reply = [self command:[NSString stringWithFormat:@"AUTH %@", _password]];
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

- (void) subscribe:(NSArray *) channels {
    if (![self isValid]) {
        [self responseError];
        return;
    }
    KRedisReply *reply = [self command:[NSString stringWithFormat:@"SUBSCRIBE %@", [channels componentsJoinedByString:@" "]]];
    if (reply.hasErrors) {
        return;
    }
    while (true) {
        NSArray *replies = [self receive];
        if (replies.count == 0) {//出错误
            [self responseError];
            break;
        }
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
            if (self.delegate != nil && [self.delegate respondsToSelector:@selector(redisSubscribeDidReply:channel:messsage:)]) {
                NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:channelReply.stringValue, @"channel", messageReply.stringValue, @"message", nil];
                
                [self performSelectorOnMainThread:@selector(responseChannel:) withObject:info waitUntilDone:NO];
                //[self responseChannel:info];
            }
        }
    }
}

- (void) responseChannel:(NSDictionary *) info {
    NSString *channel = [info objectForKey:@"channel"];
    NSString *message = [info objectForKey:@"message"];
    [self.delegate redisSubscribeDidReply:self channel:channel messsage:message];
}

- (void) responseError {
    [self close];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(redisDidDisconnect:)]) {
        [self.delegate redisDidDisconnect:self];
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
    if (_context != NULL) {
        redisFree(_context);
        _context = NULL;
    }
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
    //[self free];
}

@end

#endif

