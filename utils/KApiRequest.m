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
#import "kitchen_init.h"

@interface KApiCacheItem : NSObject

@property (nonatomic) NSTimeInterval createdAt;
@property (nonatomic) NSTimeInterval life;
@property (nonatomic) id object;

+ (KApiCacheItem *) itemWithObject:(id) object life:(NSTimeInterval) life;
- (BOOL) isValidForLife:(NSTimeInterval) life;

@end

@implementation KApiCacheItem

@synthesize createdAt, life, object;

+ (KApiCacheItem *) itemWithObject:(id) object life:(NSTimeInterval) life {
    KApiCacheItem *item = [[KApiCacheItem alloc] init];
    item.object = object;
    item.life = life;
    item.createdAt = [[NSDate date] timeIntervalSince1970];
    return item;
}

- (BOOL) isValidForLife:(NSTimeInterval) _life {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now - self.createdAt > _life) {
        return NO;
    }
    return YES;
}

@end

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

static NSMutableDictionary *cacheFactory = nil;

- (id) initWithURLString:(NSString *) urlString {
    if (cacheFactory == nil) {
        cacheFactory = [NSMutableDictionary dictionary];
    }
    
    if (self = [self initWithURL:[NSURL URLWithString:urlString]]) {
        _url = urlString;
        _cacheType = KApiRequestCacheTypeNone;
    }
    return self;
}

- (id) initWithPath:(NSString *) path {
    if (cacheFactory == nil) {
        cacheFactory = [NSMutableDictionary dictionary];
    }
    
    NSString *urlString =  [path hasPrefix:@"http://"] ? path : [NSString stringWithFormat:@"%@%@", KApiHost, path];
    if (self = [self initWithURLString:urlString]) {
        _url = urlString;
        _cacheType = KApiRequestCacheTypeNone;
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
    NSString *response = _cachedResponseString;
    if (response) {
        SBJSON *jsonParser = [SBJSON new];
        NSDictionary *dict = [jsonParser objectWithString:response error:NULL];
        return [[KApiResponse alloc] initWithDictionary:dict];
    }
    
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
    if (_cachedResponseImage) {
        return _cachedResponseImage;
    }
    return [UIImage imageWithData:self.responseData];
}

- (NSString *) requestURL {
    return _url;
}

- (NSString *) requestBody {
    [self buildPostBody];
    return [[NSString alloc] initWithData:self.postBody encoding:NSUTF8StringEncoding];
}

- (void) cachedRequest:(KApiRequestCacheType)cacheType life:(NSTimeInterval) seconds {
    _cacheType = cacheType;
    _cacheSeconds = seconds;
    
    [self buildPostBody];
    NSString *uniqueId = [[NSString stringWithFormat:@"URL:%@_PARAMS:%@", [self requestURL], [self requestBody]] md5];
    _cacheUniqueId = uniqueId;
    
    //普通数据
    if (cacheType == KApiRequestCacheTypeData) {
        KApiCacheItem *cache = [cacheFactory objectForKey:uniqueId];
        if (cache && [cache isValidForLife:seconds]) {
            _cachedResponseString = cache.object;
            if (self.requestCompletionBlock) {
                self.requestCompletionBlock();
            }
        }
        else {
            self.delegate = self;
            [self startAsynchronous];
        }
    }
    
    //图片数据
    else if (cacheType == KApiRequestCacheTypeImage) {
        NSString *fileName = [[[KApp defaultApp] documentPathFor:@"/cache/images/"] stringByAppendingFormat:@"%@.image", uniqueId];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL cached = NO;
        if ([fileManager fileExistsAtPath:fileName]) {
            NSDictionary *attributes = [fileManager attributesOfItemAtPath:fileName error:nil];
            NSDate *createdDate = [attributes objectForKey:NSFileCreationDate];
            NSTimeInterval currentLife = [[NSDate date] timeIntervalSinceDate:createdDate];
            if (currentLife < _cacheSeconds) {
                cached = YES;
                
                _cachedResponseImage = [UIImage imageWithContentsOfFile:fileName];
                
                if (self.requestCompletionBlock) {
                    self.requestCompletionBlock();
                }
            }
        }
        if (!cached) {
            self.delegate = self;
            [self startAsynchronous];
        }
    }
}

#pragma mark Delegate
- (void) requestFinished:(ASIHTTPRequest *) request {
    if (_cacheType == KApiRequestCacheTypeNone) {
        return;
    }
    if (self.responseStatusCode == 200) {
        if (_cacheType == KApiRequestCacheTypeData) {
            SBJSON *jsonParser = [SBJSON new];
            NSDictionary *dict = [jsonParser objectWithString:self.responseString error:NULL];
            if (dict != nil) {
                _cachedResponseString = self.responseString;
                
                [cacheFactory setObject:[KApiCacheItem itemWithObject:_cachedResponseString life:_cacheSeconds] forKey:_cacheUniqueId];
            }
        }
        else if (_cacheType == KApiRequestCacheTypeImage) {
            if (self.responseImage != nil) {
                NSData *data = UIImageJPEGRepresentation(self.responseImage, 1.0);
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSString *fileName = [[[KApp defaultApp] documentPathFor:@"/cache/images/"] stringByAppendingFormat:@"%@.image", _cacheUniqueId];
                if ([fileManager fileExistsAtPath:fileName]) {
                    [fileManager removeItemAtPath:fileName error:nil];
                }
                
                NSString *directory = [[KApp defaultApp] documentPathFor:@"/cache/images/"];
                if (![fileManager fileExistsAtPath:directory]) {
                    [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
                }
                [data writeToFile:fileName atomically:YES];
            }
        }
    }
}

@end