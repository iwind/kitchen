//
//  amqp-objc.h
//  RabbitMQT
//
//  Created by Liu Xiangchao on 1/27/13.
//
//

#ifndef AMQP_OBJC
#define AMQP_OBJC

#import "AMQPConnection.h"
#import "AMQPChannel.h"
#import "AMQPExchange.h"
#import "AMQPQueue.h"
#import "AMQPEnvelope.h"
#import "AMQPException.h"

#define AMQP_BYTES_TO_NSSTRING(x) [[NSString alloc] initWithBytes:x.bytes length:x.len encoding:NSUTF8StringEncoding]

#endif
