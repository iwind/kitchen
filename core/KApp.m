//
//  KApp.m
//  ZhiTiao
//
//  Created by LiuXiangChao on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KApp.h"
#import "KExtension.h"
#import "KNetwork.h"

@interface KApp ()

@end

@implementation KApp

static KApp *kApp;

+ (KApp *) defaultApp {
    if (kApp == nil) {
        kApp = [[KApp alloc] init];
    }
    return kApp;
}

- (id) init {
    if (self = [super init]) {
        _userId = 0;
    }
    return self;
}

- (NSString *) resourcePath {
    return [[NSBundle mainBundle] resourcePath];
}
- (NSString *) resourcePathFor:(NSString *) name {
    return [[NSBundle mainBundle] pathForResource:name ofType:@""];
}

- (NSString *) documentPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

- (NSString *) documentPathFor:(NSString *) name {
    return [NSString stringWithFormat:@"%@/%@", [self documentPath], name];
}

- (NSString *) tmpPath {
    return NSTemporaryDirectory();
}

- (NSString *) tmpPathFor:(NSString *) name {
    return [NSString stringWithFormat:@"%@/%@", [self tmpPath], name];
}

- (id) option:(NSString *) keys {
    if (!_options) {
        _options = [NSDictionary dictionaryWithContentsOfFile:[self resourcePathFor:@"kitchen.plist"]];
    }
    return [_options objectForPath:keys];
}

- (void) call:(NSString *) tel {
    NSURL *url = [NSURL URLWithString:[@"telprompt://" stringByAppendingString:tel]]; 
    [[UIApplication  sharedApplication] openURL:url]; 
}

- (NSString *) uniqueId {
    if (_uniqueId == nil) {
        NSString *unique = [NSString stringWithFormat:@"kitchen_unique_%@", [[KNetwork defaultNetwork] macAddress]];
        _uniqueId = [unique md5];
    }
    return _uniqueId;
}

- (void) setUserId:(int) userId {
    if (_userId != userId) {
        _userId = userId;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KAppUserChangedNotification object:[NSNumber numberWithInt:_userId]];
    }
}

- (int) userId {
    return _userId;
}

- (BOOL) deviceSizeIs3_5 {
    UIScreen *screen = [UIScreen mainScreen];
    return (screen.bounds.size.height == 480.0);
}

- (BOOL) deviceSizeIs4_0 {
    UIScreen *screen = [UIScreen mainScreen];
    return (screen.bounds.size.height == 568.0);
}

- (BOOL) deviceIsIOS7 {
    return ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending);
}

@end
