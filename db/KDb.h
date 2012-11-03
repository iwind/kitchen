//
//  KDb.h
//  TestTransform
//
//  Created by LiuXiangChao on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@class KStatement;

@interface KDb : NSObject {
    sqlite3 *_sqlite;
    BOOL _isReady;
    NSString *_dbPath;
}

+ (KDb *) defaultDb;
- (NSArray *) tableNames;
- (BOOL) exec:(NSString *) sql;
- (KStatement *) statement:(NSString *) sql, ...;
- (sqlite3_int64) lastInsertId;
- (void) close;
- (void) reload;

- (int) errorCode;
- (NSString *) errorMessage;

@end

@interface KStatement : NSObject {
@private
    sqlite3_stmt *_stmt;
}

- (id) initWithStmt:(sqlite3_stmt *)sqlite3Stmt;
- (int) exec;
- (BOOL) next;
- (BOOL) rewind;

- (int) intAtIndex:(int) index;
- (BOOL) boolAtIndex:(int) index;
- (double) doubleAtIndex:(int) index;
- (NSString *) stringAtIndex:(int) index;
- (const void *) bytesAtIndex:(int) index;
- (NSData *) dataAtIndex:(int) index;
- (UIImage *) imageAtIndex:(int) index;
- (int) lengthAtIndex:(int) index;

- (int) indexOfCol:(NSString *) colName;
- (int) intAtCol:(NSString *) colName;
- (BOOL) boolAtCol:(NSString *) colName;
- (double) doubleAtCol:(NSString *) colName;
- (NSString *) stringAtCol:(NSString *) colName;
- (const void *) bytesAtCol:(NSString *) colName;
- (NSData *) dataAtCol:(NSString *) colName;
- (UIImage *) imageAtCol:(NSString *) colName;
- (int) lengthAtCol:(NSString *) colName;


- (void) bindNullAtIndex:(int) index;
- (void) bindIntAtIndex:(int) index value:(int) value;
- (void) bindBoolAtIndex:(int) index value:(BOOL) value;
- (void) bindDoubleAtIndex:(int) index value:(double) value;
- (void) bindStringAtIndex:(int) index value:(NSString *) value;
- (void) bindDataAtIndex:(int)index value:(NSData *)value;

- (void) bindNullAtParam:(NSString *) param;
- (void) bindIntAtParam:(NSString *) param value:(int) value;
- (void) bindBoolAtParam:(NSString *) param value:(BOOL) value;
- (void) bindDoubleAtParam:(NSString *) param value:(double) value;
- (void) bindStringAtParam:(NSString *) param value:(NSString *) value;
- (void) bindDataAtParam:(NSString *)param value:(NSData *)value;

- (void) free;

- (int) intValue;
- (BOOL) boolValue;
- (double) doubleValue;
- (NSString *) stringValue;

@end
