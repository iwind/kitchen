//
//  RSyncUpdate.h
//  Track
//
//  Created by Liu Xiangchao on 10/19/12.
//
//

#import <Foundation/Foundation.h>

@interface KSyncUpdate : NSObject

@property (nonatomic) int version;
@property (nonatomic) NSString *dataType;
@property (nonatomic) NSString *action;
@property (nonatomic) NSDictionary *data;

- (id) initWithDictionary:(NSDictionary *) updateDictionary;
- (NSDictionary *) asDictionary;

- (id) fetch:(NSString *) dataName;
- (int) fetchInt:(NSString *) dataName;
- (float) fetchFloat:(NSString *) dataName;
- (double) fetchDouble:(NSString *) dataName;
- (BOOL) fetchBool:(NSString *) dataName;

- (NSString *) uuid;

@end
