//
//  KSettings.h
//  Track
//
//  Created by LiuXiangChao on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSettings : NSObject {
    NSString *_version;
}

@property (nonatomic) BOOL isShared;

+ (id) defaultSettings;
+ (id) sharedSettings;

- (NSString *) version;
- (NSComparisonResult) compareVersion:(NSString *) version;
- (void) updateVersion:(NSString *) version;

- (void) updateValue:(NSString *) value forKey:(NSString *) key;
- (NSString *) stringForKey:(NSString *) key;
- (int) intForKey:(NSString *) key;
- (BOOL) boolForKey:(NSString *) key;
- (double) doubleForKey:(NSString *) key;

@end
