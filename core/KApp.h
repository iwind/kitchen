//
//  KApp.h
//  ZhiTiao
//
//  Created by LiuXiangChao on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KController.h"

#define KAppUserChangedNotification @"KAppUserChangedNotification"

@interface KApp : NSObject {
@private
    NSDictionary *_options;
    int _userId;
    NSString *_uniqueId;
}

+ (KApp *) defaultApp;
- (NSString *) resourcePath;
- (NSString *) resourcePathFor:(NSString *) name;

- (NSString *) documentPath;
- (NSString *) documentPathFor:(NSString *) name;

- (NSString *) tmpPath;
- (NSString *) tmpPathFor:(NSString *) name;

- (id) option:(NSString *) keys;
- (void) call:(NSString *) tel;
- (NSString *) uniqueId;

- (void) setUserId:(int) userId;
- (int) userId;

@end
