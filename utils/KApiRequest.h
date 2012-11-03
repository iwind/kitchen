//
//  KApiRequest.h
//  Kitchen
//
//  Created by iwind on 8/10/09.
//  Copyright 2009 Ometworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

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


@interface KApiRequest : ASIFormDataRequest {
    
}

- (id) initWithURLString:(NSString *) urlString;
- (id) initWithPath:(NSString *) path;

- (void) addPostInt:(int) value forKey:(NSString *) key;
- (void) setPostInt:(int) value forKey:(NSString *) key;

- (KApiResponse *) responseApi;
- (UIImage *) responseImage;

@end