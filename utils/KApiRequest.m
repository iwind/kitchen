//
//  KApiRequest.m
//  Kitchen
//
//  Created by iwind on 8/10/09.
//  Copyright 2009 Ometworks. All rights reserved.
//

#import "KApiRequest.h"
#import "KExtension.h"
#import "JSON.h"
#import "KApp.h"
#import "kitchen_util.h"

@implementation KApiResponse

- (id) initWithDictionary:(NSDictionary *) dic {
	if (self = [super init]) {
		_data = [dic objectForPath:@"data"];
		_code = [[dic objectForPath:@"code"] intValue];
		_message = [dic objectForPath:@"message"];
	}
	return self;
}

- (NSDictionary *) data {
	return _data;
}

- (id) data:(NSString *) keys {
	return [_data objectForPath:keys];
}

- (NSString *) stringData:(NSString *) keys {
    id value = [self data:keys];
    if (value == nil) {
        return @"";
    }
    NSString *stringValue = [NSString stringWithFormat:@"%@", value];
    if ([stringValue isEqualToString:@"<null>"]) {
        return @"";
    }
    return stringValue;
}

- (int) intData:(NSString *) keys {
    return [[self data:keys] intValue];
}

- (BOOL) boolData:(NSString *) keys {
    return [[self data:keys] boolValue];
}

- (int) code {
	return _code;
}

- (NSString *) message {
	return _message;
}

@end

@implementation KApiRequest

- (id) initWithURLString:(NSString *) urlString {
    if (self = [self initWithURL:[NSURL URLWithString:urlString]]) {
        
    }
    return self;
}

- (id) initWithPath:(NSString *) path {
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [[KApp defaultApp] option:@"api.host"], path];
    if (self = [self initWithURLString:urlString]) {
        
    }
    return self;
}

- (void) addPostInt:(int) value forKey:(NSString *) key {
    [self addPostValue:[NSString stringWithFormat:@"%d", value] forKey:key];
}

- (void) setPostInt:(int) value forKey:(NSString *) key {
    [self setPostValue:[NSString stringWithFormat:@"%d", value] forKey:key];
}

- (KApiResponse *) responseApi {
    if (self.responseString == nil || ![self.responseString isKindOfClass:[NSString class]]) {
        return nil;
    }
    if (self.responseStatusCode == 200) {
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *dict = [jsonParser objectWithString:self.responseString error:NULL];
        return [[KApiResponse alloc] initWithDictionary:dict];
    }
    return [[KApiResponse alloc] initWithDictionary:[NSDictionary dictionary]];
}

- (UIImage *) responseImage {
    return [UIImage imageWithData:self.responseData];
}

@end