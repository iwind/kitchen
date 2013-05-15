//
//  KApiRequest.h
//  Kitchen
//
//  Created by iwind on 8/10/09.
//  Copyright 2009 Ometworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

typedef enum {
    KApiRequestCacheTypeNone = 0,
    KApiRequestCacheTypeImage = 1,
    KApiRequestCacheTypeData = 2,
    KApiRequestCacheTypeBigData = 3
} KApiRequestCacheType;

@interface KApiResponse : NSObject {
@private
	NSDictionary *_data;
	int _code;
	NSString *_message;
}

- (id) initWithDictionary:(NSDictionary *) dic;
- (NSDictionary *) data;
- (id) data:(NSString *) keys;
- (NSString *) stringData:(NSString *) keys;
- (int) intData:(NSString *) keys;
- (BOOL) boolData:(NSString *) keys;
- (int) code;
- (NSString *) message;

@end


@interface KApiRequest : ASIFormDataRequest <ASIHTTPRequestDelegate> {
@private
    NSString *_url;
    
    NSString *_cachedResponseString;
    KApiRequestCacheType _cacheType;
    NSTimeInterval _cacheSeconds;
    NSString *_cacheUniqueId;
    UIImage *_cachedResponseImage;
}

- (id) initWithURLString:(NSString *) urlString;
- (id) initWithPath:(NSString *) path;

- (void) addPostInt:(int) value forKey:(NSString *) key;
- (void) setPostInt:(int) value forKey:(NSString *) key;

- (KApiResponse *) responseApi;
- (UIImage *) responseImage;

- (NSString *) requestURL;
- (NSString *) requestBody;

- (void) cachedRequest:(KApiRequestCacheType)cacheType life:(NSTimeInterval) seconds;

@end