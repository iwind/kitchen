//
//  KServerNotification.h
//  Track
//
//  Created by Liu Xiangchao on 10/28/12.
//
//

#import <Foundation/Foundation.h>

@interface KServerNotification : NSObject

@property (nonatomic) int senderId;
@property (nonatomic) int userId;
@property (nonatomic) NSString *body;
@property (nonatomic) int templateId;
@property (nonatomic) NSDictionary *params;
@property (nonatomic) int createdAt;

@end
