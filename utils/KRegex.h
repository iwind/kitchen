//
//  KRegex.h
//
//  Created by iwind on 9/17/09.
//  Copyright 2009 Bokan Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegexKitLite.h"

typedef enum {
	KRegexOptionsNone = RKLNoOptions,
	KRegexOptionsNoCase = RKLCaseless,
	KRegexOptionsComments = RKLComments,
	KRegexOptionsDotAll = RKLDotAll,
	KRegexOptionsMultiline = RKLMultiline,
	KRegexOptionsUnicodeWordBoundaries = RKLUnicodeWordBoundaries
} KRegexOption;

@interface KRegexCapture : NSObject {
@private	
	NSRange _range;
	NSString *_string;
}

- (id) initWithRange:(NSRange) range string:(NSString *) string;

@property(readwrite) NSRange range;
@property(nonatomic, retain) NSString *string;

@end

@interface KRegexMatch : NSObject {
@private	
	NSRange _range;
	NSMutableArray *_captures;
}

- (void) setRange:(NSRange) range;
- (void) addCapture:(KRegexCapture *) capture;

- (NSRange) range;
- (NSArray *) captures;
- (KRegexCapture *) capture:(int) index;

@end

@interface NSString(KRegex)

- (NSArray *) matches:(NSString *) regex options:(KRegexOption) options;
- (KRegexMatch *) match:(NSString *) regex options:(KRegexOption) options;

@end