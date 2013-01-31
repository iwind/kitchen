//
//  AMQPConnection.h
//  RabbitMQT
//
//  Created by Liu Xiangchao on 1/27/13.
//
//

#import <Foundation/Foundation.h>
#import "amqp.h"

@protocol AMQPConnectionDelegate;

@interface AMQPConnection : NSObject {
    amqp_connection_state_t _connection;
    int _sockfd;
}

@property (nonatomic) NSString *host;
@property (nonatomic) int port;
@property (nonatomic) NSString *vhost;
@property (nonatomic) NSString *login;
@property (nonatomic) NSString *password;
@property (nonatomic) NSObject  <AMQPConnectionDelegate> *delegate;

- (BOOL) connect;
- (BOOL) reconnect;
- (void) close;
- (BOOL) isConnected;

- (amqp_connection_state_t) nativeConnection;
- (int) nativeSockFd;

- (void) checkLastOperation:(NSString *) cause, ...;

- (void) fireReadError;

@end

@protocol AMQPConnectionDelegate <NSObject>

@optional
- (void) AMQPDidDisconnect:(AMQPConnection *) connection;
- (void) AMQPDidConnect:(AMQPConnection *) connection;
- (void) AMQPDidNotLogined:(AMQPConnection *) connection;
- (void) AMQPDidReadError:(AMQPConnection *) connection;

@end

