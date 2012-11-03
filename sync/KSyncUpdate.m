//
//  RSyncUpdate.m
//  Track
//
//  Created by Liu Xiangchao on 10/19/12.
//
//

#import "KSyncUpdate.h"
#import "kitchen.h"

@implementation KSyncUpdate

@synthesize version, dataType, action, data;

- (id) initWithDictionary:(NSDictionary *) updateDictionary {
    if (self = [super init]) {
        self.dataType = [updateDictionary objectForKey:@"data_type"];
        self.action = [updateDictionary objectForKey:@"action"];
        self.version = [updateDictionary intForPath:@"version"];
        self.data = [updateDictionary objectForKey:@"data"];
    }
    return self;
}

- (id) init {
    if (self = [super init]) {
        self.version = 0;
    }
    return self;
}

- (NSDictionary *) asDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:self.version] forKey:@"version"];
    [dict setObject:self.dataType forKey:@"data_type"];
    [dict setObject:self.action forKey:@"action"];
    [dict setObject:self.data forKey:@"data"];
    return dict;
}

- (id) fetch:(NSString *) dataName {
    return [self.data objectForPath:dataName];
}

- (int) fetchInt:(NSString *) dataName {
    return [self.data intForPath:dataName];
}

- (float) fetchFloat:(NSString *) dataName {
    NSNumber *number = [self.data objectForPath:dataName];
    return [number floatValue];
}

- (double) fetchDouble:(NSString *) dataName {
    NSNumber *number = [self.data objectForPath:dataName];
    return [number doubleValue];
}

- (BOOL) fetchBool:(NSString *) dataName {
    return ([self fetchInt:dataName] == 1);
}

- (NSString *) uuid {
    return [self fetch:@"rock_uuid"];
}

@end
