//
//  KNetwork.h
//  TestTransform
//
//  Created by Liu Xiangchao on 11/5/12.
//
//

#import <Foundation/Foundation.h>

@interface KNetwork : NSObject {
@private
    NSString *_macAddress;
}

+ (id) defaultNetwork;
- (NSString *) macAddress;

@end
