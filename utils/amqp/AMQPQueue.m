//
//  AMQPQueue.m
//  RabbitMQT
//
//  Created by Liu Xiangchao on 1/27/13.
//
//

#import "AMQPQueue.h"

@implementation AMQPQueue

@synthesize name, isDurable, isExclusive, isPassive, canAutoDelete;

- (id) initWithChannel:(AMQPChannel *) channel {
    if (self = [super init]) {
        _channel = channel;
        
        self.name = @"";
        self.isDurable = NO;
        self.isExclusive = NO;
        self.isPassive = NO;
        self.canAutoDelete = YES;
    }
    return self;
}

- (void) declare {
    amqp_queue_declare_ok_t *result = amqp_queue_declare(_channel.connection.nativeConnection, 1, amqp_cstring_bytes([self.name UTF8String]), self.isPassive ? 1 : 0, self.isDurable ? 1 : 0, self.isExclusive ? 1 : 0, self.canAutoDelete ? 1 : 0, amqp_empty_table);
    
    [_channel.connection checkLastOperation:@"Failed to declare queue '%@'", self.name];
    
    _queueName = amqp_bytes_malloc_dup(result->queue);
}

- (void) bindWithExchange:(AMQPExchange *) exchange routingKey:(NSString *) routingKey {
    amqp_queue_bind(_channel.connection.nativeConnection, 1, _queueName, amqp_cstring_bytes([exchange.name UTF8String]), amqp_cstring_bytes([routingKey UTF8String]), amqp_empty_table);
    
    [_channel.connection checkLastOperation:@"Failed to bind {queue:'%@', exchange:'%@', routing key:'%@'}", self.name, exchange.name, routingKey];
}

- (void) unbindWithExchange:(AMQPExchange *) exchange routingKey:(NSString *) routingKey {
    amqp_queue_unbind(_channel.connection.nativeConnection, 1,
                      amqp_cstring_bytes([self.name UTF8String]),
                      amqp_cstring_bytes([exchange.name UTF8String]),
                      amqp_cstring_bytes([routingKey UTF8String]),
                      amqp_empty_table);
    [_channel.connection checkLastOperation:@"Failed to unbind {queue:'%@', exchange:'%@', routing key:'%@'}", self.name, exchange.name, routingKey];
}

- (void) consume:(void (^)(AMQPEnvelope *envelope))callback {
    amqp_connection_state_t connection = _channel.connection.nativeConnection;

    amqp_basic_consume(_channel.connection.nativeConnection, 1, amqp_cstring_bytes([self.name UTF8String]), amqp_empty_bytes, 0, 1, 0, amqp_empty_table);
    [_channel.connection checkLastOperation:@"Failed to consume queue:%@", self.name];
    
    dispatch_queue_t task = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(task,
        ^{
            while (YES) {
                amqp_frame_t frame;
                int result = -1;
                size_t receivedBodyBytes = 0;
                size_t bodySize = -1;
                amqp_bytes_t body;
                
                amqp_maybe_release_buffers(connection);
                
                // Frame #1: method frame with method basic.deliver
                result = amqp_simple_wait_frame(connection, &frame);
                if (result < 0) {
                    [_channel.connection fireReadError];
                   return;
                }
                if (frame.frame_type != AMQP_FRAME_METHOD || frame.payload.method.id != AMQP_BASIC_DELIVER_METHOD) {
                   continue;
                }
                amqp_basic_deliver_t *delivery = (amqp_basic_deliver_t*)frame.payload.method.decoded;
               
                // Frame #2: header frame containing body size
                result = amqp_simple_wait_frame(connection, &frame);
                if (result < 0) {
                    [_channel.connection fireReadError];
                   return;
                }
               
                if (frame.frame_type != AMQP_FRAME_HEADER) {
                    [_channel.connection fireReadError];
                    return;
                }
                amqp_basic_properties_t *properties = (amqp_basic_properties_t*)frame.payload.properties.decoded;
               
                bodySize = frame.payload.properties.body_size;
                receivedBodyBytes = 0;
                body = amqp_bytes_malloc(bodySize);
               
                // Frame #3+: body frames
                while (receivedBodyBytes < bodySize) {
                   result = amqp_simple_wait_frame(connection, &frame);
                   if (result < 0) {
                       [_channel.connection fireReadError];
                       return;
                   }
                   
                   if (frame.frame_type != AMQP_FRAME_BODY) {
                       [_channel.connection fireReadError];
                       return;
                   }
                   
                    receivedBodyBytes += frame.payload.body_fragment.len;
                   
                    memcpy(body.bytes, frame.payload.body_fragment.bytes, frame.payload.body_fragment.len);
                }
                
                AMQPEnvelope *envelope = [[AMQPEnvelope alloc] initWithFrameBody:body delivery:delivery properties:properties];
                amqp_bytes_free(body);
                
                callback(envelope);
           }
           
       });
}

- (void) dealloc {
    amqp_bytes_free(_queueName);
}

@end
