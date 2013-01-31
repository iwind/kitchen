//
//  AMQPConnection.m
//  RabbitMQT
//
//  Created by Liu Xiangchao on 1/27/13.
//
//

#import "AMQPConnection.h"
#import "amqp-objc.h"
#import "Reachability.h"

@implementation AMQPConnection

@synthesize host, port, vhost, login, password, delegate;

- (id) init {
    if (self = [super init]) {
        host = @"localhost";
        port = 5672;
        vhost = @"/";
        login = @"guest";
        password = @"guest";
    }
    return self;
}

- (BOOL) connect {
    if ([Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable) {
        //通知未连接
        if (self.delegate && [self.delegate respondsToSelector:@selector(AMQPDidDisconnect:)]) {
            [self.delegate AMQPDidDisconnect:self];
        }
        return NO;
    }
    
    _connection = amqp_new_connection();
    _sockfd = amqp_open_socket([self.host UTF8String], self.port);
    
    if (_sockfd < 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(AMQPDidDisconnect:)]) {
            [self.delegate AMQPDidDisconnect:self];
        }
        return NO;
    }

    amqp_set_sockfd(_connection, _sockfd);
    amqp_rpc_reply_t result = amqp_login(_connection, "/", 0, 131072, 0, AMQP_SASL_METHOD_PLAIN, [self.login UTF8String], [self.password UTF8String]);
    if (result.reply_type != AMQP_RESPONSE_NORMAL && result.reply_type != AMQP_RESPONSE_NONE) {
        //通知未登录
        if (self.delegate && [self.delegate respondsToSelector:@selector(AMQPDidNotLogined:)]) {
            [self.delegate AMQPDidNotLogined:self];
        }
        
        //通知未连接
        if (self.delegate && [self.delegate respondsToSelector:@selector(AMQPDidDisconnect:)]) {
            [self.delegate AMQPDidDisconnect:self];
        }
        return NO;
    }
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(AMQPDidConnect:)]) {
        [self.delegate AMQPDidConnect:self];
    }
    
    return YES;
}

- (BOOL) reconnect {
    [self close];
    return [self connect];
}

- (void) close {
    if (_sockfd < 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(AMQPDidDisconnect:)]) {
            [self.delegate AMQPDidDisconnect:self];
        }
        return;
    }
    
    amqp_connection_close(_connection, AMQP_REPLY_SUCCESS);
    amqp_destroy_connection(_connection);
    
    _sockfd = -1;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(AMQPDidDisconnect:)]) {
        [self.delegate AMQPDidDisconnect:self];
    }
}

- (BOOL) isConnected {
    return (_sockfd > 0);
}

- (amqp_connection_state_t) nativeConnection {
    return _connection;
}

- (int) nativeSockFd {
    return _sockfd;
}

- (void) checkLastOperation:(NSString *) cause, ... {
    amqp_rpc_reply_t reply = amqp_get_rpc_reply(_connection);
    if(reply.reply_type != AMQP_RESPONSE_NORMAL && reply.reply_type != AMQP_RESPONSE_NONE) {
        va_list args;
        va_start(args, cause);
        NSString *formattedCause = [[NSString alloc] initWithFormat:cause arguments:args];
        
        [AMQPException raise:@"AMQPException" format:@"%@: %@", formattedCause, [self errorDescriptionForReply:reply]];
    }
}

- (NSString*)errorDescriptionForReply:(amqp_rpc_reply_t)reply {
	switch (reply.reply_type) {
		case AMQP_RESPONSE_NORMAL:
			return @"";
		case AMQP_RESPONSE_NONE:
			return @"missing RPC reply type";
		case AMQP_RESPONSE_LIBRARY_EXCEPTION:
			if(reply.library_error != AMQP_RESPONSE_NORMAL) {
				return [NSString stringWithFormat:@"library error:%d", reply.library_error];
			}
			else {
				return @"(end-of-stream)";
			}
		case AMQP_RESPONSE_SERVER_EXCEPTION:
        {
            switch (reply.reply.id) {
                case AMQP_CONNECTION_CLOSE_METHOD:
                {
                    amqp_connection_close_t *connectionClose = (amqp_connection_close_t *) reply.reply.decoded;
                    return AMQP_BYTES_TO_NSSTRING(connectionClose->reply_text);
                }
                case AMQP_CHANNEL_CLOSE_METHOD:
                {
                    amqp_channel_close_t *channelClose = (amqp_channel_close_t *) reply.reply.decoded;
                    return AMQP_BYTES_TO_NSSTRING(channelClose->reply_text);
                }
                default:
                    return [NSString stringWithFormat:@"unknown error %d", reply.reply.id];
            }
        }
			break;
	}
}

- (void) fireReadError {
    if (self.delegate && [self.delegate respondsToSelector:@selector(AMQPDidReadError:)]) {
        [self.delegate AMQPDidReadError:self];
    }
}

@end
