//
//  KDb.m
//  TestTransform
//
//  Created by LiuXiangChao on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KDb.h"
#import "KApp.h"
#import "sqlite_func.h"
#import "kitchen_util.h"

@interface KDb()

- (void) setup:(BOOL) force;

@end

@implementation KDb

+ (KDb *) defaultDb {
    static NSString *KitchenDbKey = @"KitchenDbKeyUser";
    
    int userId = [[KApp defaultApp] userId];
    NSMutableDictionary *dict = [[NSThread currentThread] threadDictionary];
    KDb *instance = [dict objectForKey:KitchenDbKey];
    if (instance != nil && instance.userId != userId) {
        [instance close];
        instance = nil;
    }
    
    if (instance == nil) {
        instance = [[self alloc] initWithUserId:userId];
        [dict setObject:instance forKey:KitchenDbKey];
    }
    
    return instance;
}

+ (KDb *) sharedDb {
    static NSString *KitchenDbKey = @"KitchenDbKeyShared";
    
    NSMutableDictionary *dict = [[NSThread currentThread] threadDictionary];
    KDb *instance = [dict objectForKey:KitchenDbKey];
    if (instance == nil) {
        instance = [[self alloc] initWithUserId:-1];
        [dict setObject:instance forKey:KitchenDbKey];
    }
    
    return instance;
}

- (void) setup:(BOOL) force {
    _isReady = NO;
    
    NSString *fileName;
    if (_userId < 0) {
        fileName = @"kitchen.db";
    }
    else {
        fileName = [NSString stringWithFormat:@"kitchen%d.db", _userId];
    }
    _dbPath = [[KApp defaultApp] documentPathFor:fileName];
    
    KLog(@"ready to setup database at %@", _dbPath);
    
    //建立初始数据库
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (force && [fileManager fileExistsAtPath:_dbPath]) {
        [fileManager removeItemAtPath:_dbPath error:nil];
    }
    if (![fileManager fileExistsAtPath:_dbPath]) {
        NSString *resourcePath = [[KApp defaultApp] resourcePathFor:@"kitchen.sqlite"];
        NSError *error;
        if (![fileManager copyItemAtPath:resourcePath toPath:_dbPath error:&error]) {
            
            [NSException raise:@"db setup error:%@" format:@"%@", [error localizedDescription]];
        }
        
    }
    
    //int state = sqlite3_open([_dbPath UTF8String], &_sqlite);
    int state = sqlite3_open_v2([_dbPath UTF8String], &_sqlite, SQLITE_OPEN_READWRITE|SQLITE_OPEN_NOMUTEX, NULL);
    if (state == SQLITE_OK) {
        _isReady = YES;
        
        sqlite3_create_function(_sqlite, "distance", 4, SQLITE_UTF8, NULL, &sqliteDistanceFunc, NULL, NULL);
        sqlite3_create_function(_sqlite, "near", 8, SQLITE_UTF8, NULL, &sqliteNearFunc, NULL, NULL);
    }
    else {
        KLog(@"sqlite failed to open database file (code:%d).", state);
    }
}

- (NSArray *) tableNames {
    KStatement *stmt = [self statement:@"SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    while ([stmt next]) {
        NSString *name = [stmt stringAtIndex:0];
        [array addObject:name];
    }
    [stmt free];
    return array;
}

- (id) init {
    if (self = [super init]) {
        
    }
    return self;
}

- (id) initWithUserId:(int) userId {
    if (self = [self init]) {
        _userId = userId;
        [self setup:NO];
    }
    return self;
}

- (BOOL) exec:(NSString *) sql {
    char *errorMsg;
    int state = sqlite3_exec(_sqlite, [sql UTF8String], NULL, NULL, &errorMsg);
    if (state != SQLITE_OK) {
        KLog(@"sqlite3 exec: error:%s", errorMsg);
        return NO;
    }
    return YES;
}

- (KStatement *) statement:(NSString *) sql, ... {
    sqlite3_stmt *sqlite3Stmt;
    va_list args;
    va_start(args, sql);
    NSString *newSql = [[NSString alloc] initWithFormat:sql arguments:args];
    va_end(args);
    int state = sqlite3_prepare_v2(_sqlite, [newSql UTF8String], -1, &sqlite3Stmt, NULL);
    KStatement *stmt;
    if (state == SQLITE_OK) {
        stmt = [[KStatement alloc] initWithStmt:sqlite3Stmt];
    }
    else {
        KLog(@"sqlite3 statement: failed to prepare:%@ (code:%d)", newSql, state);
    }
    return stmt;
}

- (sqlite3_int64) lastInsertId {
    return sqlite3_last_insert_rowid(_sqlite);
}

- (void) close {
    if (_isReady) {
        sqlite3_close(_sqlite);
        _isReady = NO;
    }
}

- (void) reload {
    [self close];
    [self setup:YES];
}

- (int) userId {
    return _userId;
}

- (int) errorCode {
    return sqlite3_errcode(_sqlite);
}
- (NSString *) errorMessage {
    return [NSString stringWithUTF8String:sqlite3_errmsg(_sqlite)];
}

- (void) dealloc {
    [self close];
}

@end

@implementation KStatement

- (id) initWithStmt:(sqlite3_stmt *)sqlite3Stmt {
    if (self = [super init]) {
        _stmt = sqlite3Stmt;
    }
    return self;
}

- (int) exec {
    int result = sqlite3_step(_stmt);
    if (result != SQLITE_DONE && result != SQLITE_OK && result != SQLITE_ROW) {
        KDb *db = [KDb defaultDb];
        KLog(@"sqlite error code:%d, message:%@", [db errorCode], [db errorMessage]);
    }
    return result;
}

- (BOOL) next {
    int state = sqlite3_step(_stmt);

    if (state == SQLITE_ROW) {
        return YES;
    }
    return NO;
}

- (BOOL) rewind {
    return (sqlite3_reset(_stmt) == SQLITE_OK);
}

- (int) intAtIndex:(int) index {
    return sqlite3_column_int(_stmt, index);
}

- (BOOL) boolAtIndex:(int) index {
    return ([self intAtIndex:index] > 0);
}

- (double) doubleAtIndex:(int) index {
    return sqlite3_column_double(_stmt, index);
}

- (NSString *) stringAtIndex:(int) index {
    const unsigned char *text = sqlite3_column_text(_stmt, index);
    if (text == NULL) {
        return @"";
    }
    return [NSString stringWithUTF8String:(const char *) text];
}

- (const void *) bytesAtIndex:(int) index {
    return sqlite3_column_blob(_stmt, index);
}

- (NSData *) dataAtIndex:(int) index {
    return [NSData dataWithBytes:[self bytesAtIndex:index] length:[self lengthAtIndex:index]];
}

- (int) lengthAtIndex:(int) index {
    return sqlite3_column_bytes(_stmt, index);
}

- (int) indexOfCol:(NSString *) colName {
    const char *col = [colName UTF8String];
    int count = sqlite3_column_count(_stmt);
    for (int i = 0; i < count; i ++) {
        if (strcmp(col, sqlite3_column_name(_stmt, i)) == 0) {
            return i;
        }
    }
    return -1;
}

- (int) intAtCol:(NSString *) colName {
    int index = [self indexOfCol:colName];
    if (index >= 0) {
        return [self intAtIndex:index];
    }
    [NSException raise:@"undefined col name" format:@"undefined col name '%@'", colName];
    return 0;
}

- (BOOL) boolAtCol:(NSString *) colName {
    int index = [self indexOfCol:colName];
    if (index >= 0) {
        return [self boolAtIndex:index];
    }
    [NSException raise:@"undefined col name" format:@"undefined col name '%@'", colName];
    return NO;
}

- (double) doubleAtCol:(NSString *) colName {
    int index = [self indexOfCol:colName];
    if (index >= 0) {
        return [self doubleAtIndex:index];
    }
    [NSException raise:@"undefined col name" format:@"undefined col name '%@'", colName];
    return 0.0;
}

- (NSString *) stringAtCol:(NSString *) colName {
    int index = [self indexOfCol:colName];
    if (index >= 0) {
        return [self stringAtIndex:index];
    }
    [NSException raise:@"undefined col name" format:@"undefined col name '%@'", colName];
    return @"";
}

- (const void *) bytesAtCol:(NSString *) colName {
    int index = [self indexOfCol:colName];
    if (index >= 0) {
        return [self bytesAtIndex:index];
    }
    [NSException raise:@"undefined col name" format:@"undefined col name '%@'", colName];
    return NULL;
}

- (NSData *) dataAtCol:(NSString *) colName {
    int index = [self indexOfCol:colName];
    if (index >= 0) {
        return [self dataAtIndex:index];
    }
    [NSException raise:@"undefined col name" format:@"undefined col name '%@'", colName];
    return nil;
}

- (UIImage *) imageAtCol:(NSString *) colName {
    int index = [self indexOfCol:colName];
    if (index >= 0) {
        return [self imageAtIndex:index];
    }
    [NSException raise:@"undefined col name" format:@"undefined col name '%@'", colName];
    return nil;
}

- (int) lengthAtCol:(NSString *) colName {
    int index = [self indexOfCol:colName];
    if (index >= 0) {
        return [self lengthAtIndex:index];
    }
    [NSException raise:@"undefined col name" format:@"undefined col name '%@'", colName];
    return 0;
}

- (UIImage *) imageAtIndex:(int) index {
    int length = [self lengthAtIndex:index];
    if (length > 0) {
        return [UIImage imageWithData:[NSData dataWithBytes:[self bytesAtIndex:index] length:length]];
    }
    return nil;
}

- (void) bindNullAtIndex:(int) index {
    sqlite3_bind_null(_stmt, index);
}

- (void) bindIntAtIndex:(int) index value:(int) value {
    sqlite3_bind_int(_stmt, index, value);
}

- (void) bindBoolAtIndex:(int) index value:(BOOL) value {
    [self bindIntAtIndex:index value:(value ? 1 : 0)];
}

- (void) bindDoubleAtIndex:(int) index value:(double) value {
    sqlite3_bind_double(_stmt, index, value);
}

- (void) bindStringAtIndex:(int) index value:(NSString *) value {
    sqlite3_bind_text(_stmt, index, [value UTF8String], -1, NULL);
}

- (void) bindDataAtIndex:(int)index value:(NSData *)value {
    sqlite3_bind_blob(_stmt, index, [value bytes], value.length, NULL);
}

- (void) bindNullAtParam:(NSString *) param {
    param = [@":" stringByAppendingString:param];
    int index = sqlite3_bind_parameter_index(_stmt, [param UTF8String]);
    if (index < 1) {
        KLog(@"KStatment 'bindNullAtParam:value:' undefined param:'%@'", param);
        return;
    }
    [self bindNullAtIndex:index];
}

- (void) bindIntAtParam:(NSString *) param value:(int) value {
    param = [@":" stringByAppendingString:param];
    int index = sqlite3_bind_parameter_index(_stmt, [param UTF8String]);
    if (index < 1) {
        KLog(@"KStatment 'bindIntAtParam:value:' undefined param:'%@'", param);
        return;
    }
    [self bindIntAtIndex:index value:value];
}

- (void) bindBoolAtParam:(NSString *) param value:(BOOL) value {
    [self bindIntAtParam:param value:(value ? 1 : 0)];
}

- (void) bindDoubleAtParam:(NSString *) param value:(double) value {
    param = [@":" stringByAppendingString:param];
    int index = sqlite3_bind_parameter_index(_stmt, [param UTF8String]);
    if (index < 1) {
        [NSException raise:@"sqlite bind double param error" format:@"KStatment 'bindDoubleAtParam:value:' undefined param:'%@'", param];
        return;
    }
    [self bindDoubleAtIndex:index value:value];
}

- (void) bindStringAtParam:(NSString *) param value:(NSString *) value {
    param = [@":" stringByAppendingString:param];
    int index = sqlite3_bind_parameter_index(_stmt, [param UTF8String]);
    if (index < 1) {
        KLog(@"KStatment 'bindStringAtParam:value:' undefined param:'%@'", param);
        return;
    }
    if (value == nil || ![value isKindOfClass:[NSString class]]) {
        value = @"";
    }
    [self bindStringAtIndex:index value:value];
}

- (void) bindDataAtParam:(NSString *)param value:(NSData *)value {
    param = [@":" stringByAppendingString:param];
    int index = sqlite3_bind_parameter_index(_stmt, [param UTF8String]);
    if (index < 1) {
        KLog(@"KStatment 'bindDataAtParam:value:' undefined param:'%@'", param);
        return;
    }
    [self bindDataAtIndex:index value:value];
}

- (void) free {
    sqlite3_finalize(_stmt);
}

- (int) intValue {
    if ([self next]) {
        return [self intAtIndex:0];
    }
    return 0;
}

- (BOOL) boolValue {
    return ([self intValue] > 0);
}

- (double) doubleValue {
    if ([self next]) {
        return [self doubleAtIndex:0];
    }
    return 0.0;
}

- (NSString *) stringValue {
    if ([self next]) {
        return [self stringAtIndex:0];
    }
    return @"";
}

@end
