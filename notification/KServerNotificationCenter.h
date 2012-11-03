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
    NSMutableDictionary *_params;
    BOOL _isStarted;
}

@property (nonatomic) id <KServerNotificationCenterDelegate> delegate;

+ (id) defaultCenter;

- (void) addParam:(NSString *) param forKey:(NSString *) key;
- (void) registerHandler:(KServerNotificationHandler *) handler for:(int) templateId;
- (void) start;
@end

@protocol KServerNotificationCenterDelegate <NSObject>

- (BOOL) serverNotificationCenterShouldUpdate:(KServerNotificationCenter *) notifcationCenter;

@end

