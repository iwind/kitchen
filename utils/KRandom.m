//
//  KRandom.m
//  Framework
//
//  Created by iwind on 09-4-18.
//  Copyright 2009 Bokan Tech. All rights reserved.
//

#import "KRandom.h"


@implementation KRandom

@synthesize seed;

+ (int)randBetween:(int)min and:(int) max {
	static KRandom *bkRandom;
	if (bkRandom == nil) {
		bkRandom = [self alloc];
		bkRandom.seed = time(NULL);
	}
	
	srand(bkRandom.seed);
	int random = rand();
	bkRandom.seed += random;	
	return min + random%(max + 1 - min);
}

@end
