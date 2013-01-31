//
//  AMQPExchange.m
//  RabbitMQT
//
//  Created by Liu Xiangchao on 1/27/13.
//
//

#import "AMQPExchange.h"
#import "AMQPException.h"

@implementation AMQPExchange

@synthesize name, type, flags;

- (id) initWithChannel:(AMQPChannel *) channel {
    if (self = [super init]) {
        _channel = channel;
        self.name = @"";
        self.type = AMQPExchangeTypeFanout;
        self.flags = 0;//@TODO 需要实现
    }
    return self;
}

- (void) declare {
    NSString *typeName = @"fanout";
    switch (self.type) {
        case AMQPExchangeTypeDirect:
            typeName = @"direct";
            break;
        case AMQPExchangeTypeFanout:
            typeName = @"fanout";
            break;
        case AMQPExchangeTypeTopic:
            typeName = @"topic";
            break;
        case AMQPExchangeTypeHeader:
            typeName = @"header";
            break;
        default:
            break;
    }
    
    amqp_exchange_declare(_channel.connection.nativeConnection, 1, amqp_cstring_bytes([self.name UTF8String]), amqp_cstring_bytes([typeName UTF8String]),   0, 1, amqp_empty_table);
    [_channel.connection checkLastOperation:@"Failed to declare exchange:%@", self.name];
}

- (BOOL) publish:(NSString *) message routingKey:(NSString *) routingKey {
    if (!_channel.connection.isConnected) {
        return NO;
    }
    
    amqp_basic_properties_t props;
    props._flags = AMQP_BASIC_CONTENT_TYPE_FLAG | AMQP_BASIC_DELIVERY_MODE_FLAG;
    props.content_type = amqp_cstring_bytes("text/plain;charset=utf-8");
    props.delivery_mode = 2; /* persistent delivery mode */
    
    int r = amqp_basic_publish(_channel.connection.nativeConnection,
           1,
           amqp_cstring_bytes([self.name UTF8String]),
           amqp_cstring_bytes([routingKey UTF8String]),
           0,
           0,
           &props,
           amqp_cstring_bytes([message UTF8String]));
    @try {
        [_channel.connection checkLastOperation:@"Failed to publish to routing key:%@", routingKey];
    } @catch (AMQPException *e) {
        NSLog(@"publish error:%@", e.description);
        return NO;
    }
    return (r >= 0);
}

@end
