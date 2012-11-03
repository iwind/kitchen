//
//  MCacheEngine.h
//  MozesAlpha
//
//  Created by iwind on 8/21/09.
//  Copyright 2009 Bokan Tech. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KCacheEngine : NSObject {
@private
	NSMutableArray *_keys;
	NSMutableArray *_values;
	NSMutableArray *_maxAges;
}

+ (id) defaultEngine;
- (void) writeKey:(NSString *) key value:(id) value;
- (void) writeKey:(NSString *) key value:(id) value ttl:(float) ttl;
- (id) read:(NSString *) key;
- (void) delete:(NSString *) key;
- (void) deleteAtIndex:(int) index;
- (void) clear;
- (void) gc;
- (void) close;
- (int) count;

@end
