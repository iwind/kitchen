//
//  AMQPQueue.h
//  RabbitMQT
//
//  Created by Liu Xiangchao on 1/27/13.
//
//

#import <Foundation/Foundation.h>
#import "AMQPChannel.h"
#import "AMQPExchange.h"
#import "AMQPEnvelope.h"

@interface AMQPQueue : NSObject {
@private
    AMQPChannel *_channel;
    amqp_bytes_t _queueName;
}

@property (nonatomic) NSString *name;
@property (nonatomic) BOOL isDurable;
@property (nonatomic) BOOL isPassive;
@property (nonatomic) BOOL isExclusive;
@property (nonatomic) BOOL canAutoDelete;

- (id) initWithChannel:(AMQPChannel *) channel;
- (void) declare;
- (void) bindWithExchange:(AMQPExchange *) exchange routingKey:(NSString *) routingKey;
- (void) unbindWithExchange:(AMQPExchange *) exchange routingKey:(NSString *) routingKey;
- (void) consume:(void (^)(AMQPEnvelope *envelope)) callback;

@end
