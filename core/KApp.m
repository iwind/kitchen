//
//  KApp.m
//  ZhiTiao
//
//  Created by LiuXiangChao on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KApp.h"
#import "KExtension.h"

@interface KApp ()

@end

@implementation KApp

static KApp *kApp;

+ (KApp *) sharedApp {
    if (kApp == nil) {
        kApp = [[KApp alloc] init];
    }
    return kApp;
}

- (id) init {
    self = [super init];
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

@end
