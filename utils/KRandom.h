//
//  KRandom.h
//  Framework
//
//  Created by iwind on 09-4-18.
//  Copyright 2009 Bokan Tech. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KRandom : NSObject {
	int seed;
}

@property (readwrite) int seed;

+ (int)randBetweenMin:(int)min max:(int) max;

@end
