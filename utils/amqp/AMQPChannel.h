//
//  AMQPChannel.h
//  RabbitMQT
//
//  Created by Liu Xiangchao on 1/27/13.
//
//

#import <Foundation/Foundation.h>
#import "AMQPConnection.h"

@interface AMQPChannel : NSObject {
@private
    AMQPConnection *_connection;
}

- (id) initWithConnection:(AMQPConnection *) connection;
- (AMQPConnection *) connection;
- (void) close;

@end
