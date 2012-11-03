//
//  KServerNotificationHandler.h
//  Track
//
//  Created by Liu Xiangchao on 10/28/12.
//
//

#import <Foundation/Foundation.h>
#import "KServerNotification.h"

@interface KServerNotificationHandler : NSObject

- (void) handle:(KServerNotification *) notification;

@end
