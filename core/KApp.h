//
//  KApp.h
//  ZhiTiao
//
//  Created by LiuXiangChao on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KController.h"

@interface KApp : NSObject {
@private
    NSDictionary *_options;
}

+ (KApp *) defaultApp;
- (NSString *) resourcePath;
- (NSString *) resourcePathFor:(NSString *) name;
- (NSString *) documentPath;
- (NSString *) documentPathFor:(NSString *) name;
- (NSString *) tmpPath;
- (id) option:(NSString *) keys;
- (void) call:(NSString *) tel;
- (NSString *) uniqueId;

@end
