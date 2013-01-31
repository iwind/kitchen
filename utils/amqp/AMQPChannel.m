//
//  AMQPChannel.m
//  RabbitMQT
//
//  Created by Liu Xiangchao on 1/27/13.
//
//

#import "AMQPChannel.h"

@implementation AMQPChannel

- (id) initWithConnection:(AMQPConnection *) connection {
    if (self = [super init]) {
        _connection = connection;
        
        amqp_channel_open([connection nativeConnection], 1);
    
        [_connection checkLastOperation:@"Failed to open channel"];
    }
    return self;
}

- (AMQPConnection *) connection {
    return _connection;
}

- (void) close {
    amqp_channel_close(_connection.nativeConnection, 1, AMQP_REPLY_SUCCESS);
}

@end
