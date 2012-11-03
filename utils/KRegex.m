//
//  KRegex.m
//
//  Created by iwind on 9/17/09.
//  Copyright 2009 Bokan Tech. All rights reserved.
//

#import "KRegex.h"

@implementation KRegexCapture

@synthesize range = _range, string = _string;

- (id) initWithRange:(NSRange) range string:(NSString *) string {
	if (self = [super init]) {
		_range = range;
		_string = string;
	}
	return self;
}

- (NSString *) description {
	return [NSString stringWithFormat:@"\"%@\" in %@", _string, NSStringFromRange(_range)];
}

@end

@implementation KRegexMatch

- (id) init {
	if (self = [super init]) {
		_captures = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) setRange:(NSRange) range {
	_range = range;
}

- (void) addCapture:(KRegexCapture *) capture {
	[_captures addObject:capture];
}

- (NSRange) range {
	return _range;
}
- (NSArray *) captures {
	return _captures;
}

- (KRegexCapture *) capture:(int) index {
	return [_captures objectAtIndex:index];
}

#pragma mark -
- (void) dealloc {
	_captures = nil;
}

@end

@implementation NSString(KRegex)

- (NSArray *) matches:(NSString *) regex options:(KRegexOption) options {
	NSMutableArray *matches = [[NSMutableArray alloc] init];
	NSRange range = NSMakeRange(0, self.length);
	NSError *error;
	while([self isMatchedByRegex:regex options:options inRange:range error:&error]) {
		KRegexMatch *match = [[KRegexMatch alloc] init];
		
		//range
		NSRange resultRange = [self rangeOfRegex:regex options:options inRange:range capture:0 error:&error];
		[match setRange:resultRange];
		
		//captures
		NSString *capture0 = [self substringWithRange:resultRange];
		for (int i = 0;;i++) {
			@try {
				NSRange captureRange = [capture0 rangeOfRegex:regex options:options inRange:NSMakeRange(0, capture0.length) capture:i error:&error];
				NSString *captureString = [capture0 substringWithRange:captureRange];
				KRegexCapture *capture  = [[KRegexCapture alloc] initWithRange:captureRange string:captureString];
				[match addCapture:capture];
				capture = nil;
			}
			@catch (NSException *e) {
				break;
			}
		}
		
		
		[matches addObject:match];
		match = nil;
		
		range = NSMakeRange(resultRange.location + resultRange.length, self.length - resultRange.location - resultRange.length);
	}
	
	return matches;
}

- (KRegexMatch *) match:(NSString *) regex options:(KRegexOption) options {
	NSArray *matches = [self matches:regex options:options];
	if ([matches count] > 0) {
		return [matches objectAtIndex:0];
	}
	return nil;
}

@end