//
//  MCacheEngine.m
//  Kitchen
//
//  Created by iwind on 8/21/09.
//  Copyright 2009 Bokan Tech. All rights reserved.
//

#import "KCacheEngine.h"


@implementation KCacheEngine

+ (id) defaultEngine {
	static KCacheEngine *_cacheEngine;
	if (!_cacheEngine) {
		_cacheEngine = [[KCacheEngine alloc] init];
	}
	return _cacheEngine;
}

- (void) __init {
	_keys = [[NSMutableArray alloc] init];
	_values = [[NSMutableArray alloc] init];
	_maxAges = [[NSMutableArray alloc] init];
}

- (id) init {
	if (self = [super init]) {
		[self __init];
	}
	return self;
}

- (void) writeKey:(NSString *) key value:(id) value {
	[self writeKey:key value:value ttl:3600.0f];
}

- (void) writeKey:(NSString *) key value:(id) value ttl:(float) ttl {
	if ([_keys containsObject:key]) {
		int index = [_keys indexOfObject:key];
		[_values replaceObjectAtIndex:index withObject:value];
		[_maxAges replaceObjectAtIndex:index withObject:[NSNumber numberWithFloat:(time(NULL) + ttl)]];
	}
	else {
		[_keys addObject:key];
		[_values addObject:value];
		[_maxAges addObject:[NSNumber numberWithFloat:(time(NULL) + ttl)]];
	}
}

- (id) read:(NSString *) key {
	if ([_keys containsObject:key]) {
		int index = [_keys indexOfObject:key];
		NSNumber *maxAge = [_maxAges objectAtIndex:index];
		if ([maxAge floatValue] < time(NULL)) {//expire
			[self delete:key];
			return nil;
		}
		return [_values objectAtIndex:index];
	}
	return nil;
}

- (void) delete:(NSString *) key {
	if ([_keys containsObject:key]) {
		int index = [_keys indexOfObject:key];
		[self deleteAtIndex:index];
	}
}

- (void) deleteAtIndex:(int) index {
	[_keys removeObjectAtIndex:index];
	[_values removeObjectAtIndex:index];
	[_maxAges removeObjectAtIndex:index];
}

- (void) clear {
	[_keys removeAllObjects];
	[_values removeAllObjects];
	[_maxAges removeAllObjects];
}

- (void) gc {
	int count = [_keys count];
	int now = time(NULL);
	NSMutableArray *_expireKeys = [[NSMutableArray alloc] init];
	for (int i = 0; i < count; i ++) {
		NSNumber *maxAge = [_maxAges objectAtIndex:i];
		if ([maxAge floatValue] < now) {
			[_expireKeys addObject:[_keys objectAtIndex:i]];
		}
	}
	for (NSString *key in _expireKeys) {
		[self delete:key];
	}
}

- (void) close {
	
}

- (int) count {
    return _keys.count;
}

@end
