//
//  AMQPEnvelope.m
//  RabbitMQT
//
//  Created by Liu Xiangchao on 1/27/13.
//
//

#import "AMQPEnvelope.h"
#import "amqp-objc.h"

@implementation AMQPEnvelope

@synthesize body, routingKey;

- (id) initWithFrameBody:(amqp_bytes_t) frameBody delivery:(amqp_basic_deliver_t *) frameDelivery properties:(amqp_basic_properties_t *)frameProperties {
    if (self = [super init]) {
        self.body = AMQP_BYTES_TO_NSSTRING(frameBody);
        self.routingKey = AMQP_BYTES_TO_NSSTRING(frameDelivery->routing_key);
    }
    return self;
}

- (void) bytesToString {
    
}


@end
