//
//  AMQPExchange.h
//  RabbitMQT
//
//  Created by Liu Xiangchao on 1/27/13.
//
//

#import <Foundation/Foundation.h>
#import "AMQPChannel.h"

typedef enum {
    AMQPExchangeTypeDirect,
    AMQPExchangeTypeFanout,
    AMQPExchangeTypeTopic,
    AMQPExchangeTypeHeader
} AMQPExchangeType;

@interface AMQPExchange : NSObject {
@private
    AMQPChannel *_channel;
}

@property (nonatomic) NSString *name;
@property (nonatomic) AMQPExchangeType type;
@property (nonatomic) int flags;

- (id) initWithChannel:(AMQPChannel *) channel;
- (void) declare;
- (BOOL) publish:(NSString *) message routingKey:(NSString *) routingKey;

@end
