//
//  KAudioPlayer.h
//  NightClub
//
//  Created by iwind on 6/17/09.
//  Copyright 2009 Bokan Tech. All rights reserved.
//

#import "kitchen_init.h"

#ifdef KITCHEN_AV_ENABLED
#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

@interface KAudioPlayer : AVAudioPlayer {
	NSString *key;
}

- (void) setKey:(NSString *) key;
- (NSString *) key;

@end

#endif
