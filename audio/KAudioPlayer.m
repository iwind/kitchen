//
//  KAudioPlayer.m
//  NightClub
//
//  Created by iwind on 6/17/09.
//  Copyright 2009 Bokan Tech. All rights reserved.
//

#import "KAudioPlayer.h"

#ifdef KITCHEN_AV_ENABLED

@implementation KAudioPlayer

- (void) setKey:(NSString *) _key {
	key = _key;
}

- (NSString *) key {
	return key;
}

@end

#endif
