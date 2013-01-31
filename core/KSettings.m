//
//  KSettings.m
//  Track
//
//  Created by LiuXiangChao on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KSettings.h"
#import "KDb.h"

@implementation KSettings

@synthesize isShared;

+ (id) defaultSettings {
    static KSettings *instance;
    static dispatch_once_t onceQueue;
    
    dispatch_once(&onceQueue, ^{
        instance = [[self alloc] initWithShared:NO];
    });
    
    return instance;
}

+ (id) sharedSettings {
    static KSettings *instance;
    static dispatch_once_t onceQueue;
    
    dispatch_once(&onceQueue, ^{
        instance = [[self alloc] initWithShared:YES];
    });
    
    return instance;
}

- (id) initWithShared:(BOOL) _isShared {
    if (self = [super init]) {
        self.isShared = _isShared;
        
        [self setup];
        
        KStatement *stmt = [[self currentDb] statement:@"SELECT value FROM k_settings WHERE name='version' LIMIT 1"];
        if ([stmt next]) {
            _version = [stmt stringAtIndex:0];
        }
        [stmt free];
    }
    return self;
}

- (void) setup {
    NSArray *names = [[self currentDb] tableNames];
    NSString *settingsTable = @"k_settings";
    if ([names containsObject:settingsTable]) {
        return;
    }
    
    [[self currentDb] exec:@"CREATE TABLE \"k_settings\" ( \"name\" VARCHAR(64,0), \"value\" VARCHAR (255,0) );"];
}

/** 单独用一个方法获取数据库指针，是为了防止多线程问题 **/
- (KDb *) currentDb {
    if (self.isShared) {
        return [KDb sharedDb];
    }
    else {
        return [KDb defaultDb];
    }
}

- (NSString *) version {
    return _version;
}

- (NSComparisonResult) compareVersion:(NSString *) version {
    if (_version == nil) {
        return NSOrderedAscending;
    }
    return [_version compare:version options:NSNumericSearch];
}

- (void) updateVersion:(NSString *) version {
    _version = version;
    [self updateValue:version forKey:@"version"];
}

- (void) updateValue:(NSString *) value forKey:(NSString *) key {
    if ([key isEqualToString:@"version"]) {
        _version = value;
    }
    
    //是否存在
    KStatement *selectStmt = [[self currentDb] statement:@"SELECT COUNT(*) FROM k_settings WHERE name=:name LIMIT 1"];
    [selectStmt bindStringAtParam:@"name" value:key];
    int count = [selectStmt intValue];
    [selectStmt free];
    
    KStatement *stmt;
    if (count > 0) {
        stmt = [[self currentDb] statement:@"UPDATE k_settings SET value=:value WHERE name=:name"];
    }
    else {
        stmt = [[self currentDb] statement:@"INSERT INTO k_settings (name,value) VALUES (:name,:value)"];
    }
    [stmt bindStringAtParam:@"value" value:value];
    [stmt bindStringAtParam:@"name" value:key];
    [stmt exec];
    [stmt free];
}

- (NSString *) stringForKey:(NSString *) key {
    KStatement *stmt = [[self currentDb] statement:@"SELECT value FROM k_settings WHERE name=:name LIMIT 1"];
    [stmt bindStringAtParam:@"name" value:key];
    if ([stmt next]) {
        NSString *ret = [stmt stringAtIndex:0];
        [stmt free];
        return ret;
    }
    [stmt free];
    return @"";
}

- (int) intForKey:(NSString *) key {
    NSString *value = [self stringForKey:key];
    if (value.length == 0) {
        return 0;
    }
    return [value intValue];
}

- (BOOL) boolForKey:(NSString *) key {
    return ([self intForKey:key] > 0);
}

- (double) doubleForKey:(NSString *) key {
    return [[self stringForKey:key] doubleValue];
}

@end
