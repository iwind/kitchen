//
//  AMQPEnvelope.h
//  RabbitMQT
//
//  Created by Liu Xiangchao on 1/27/13.
//
//

#import <Foundation/Foundation.h>
#import "amqp.h"

@interface AMQPEnvelope : NSObject

@property (nonatomic) NSString *body;
@property (nonatomic) NSString *routingKey;

- (id) initWithFrameBody:(amqp_bytes_t) frameBody delivery:(amqp_basic_deliver_t *) frameDelivery properties:(amqp_basic_properties_t *)frameProperties;

@end
