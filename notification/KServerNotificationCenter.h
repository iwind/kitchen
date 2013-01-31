//
//  KServerNotificationCenter.h
//  Track
//
//  Created by Liu Xiangchao on 10/28/12.
//
//

#import <Foundation/Foundation.h>
#import "KServerNotificationHandler.h"

@protocol KServerNotificationCenterDelegate;

@interface KServerNotificationCenter : NSObject {
@private
    NSMutableDictionary *_handlers;
    KServerNotificationHandler *_defaultHandler;
    
    NSMutableDictionary *_params;
    BOOL _isStarted;
    int _ttl;
}

@property (nonatomic) id <KServerNotificationCenterDelegate> delegate;

+ (id) defaultCenter;

- (void) setTtl:(int) ttl;
- (void) addParam:(NSString *) param forKey:(NSString *) key;
- (void) registerHandler:(KServerNotificationHandler *) handler for:(int) templateId;
- (void) registerDefaultHandler:(KServerNotificationHandler *) handler;
- (void) start;
@end

@protocol KServerNotificationCenterDelegate <NSObject>

- (BOOL) serverNotificationCenterShouldUpdate:(KServerNotificationCenter *) notifcationCenter;

@end

