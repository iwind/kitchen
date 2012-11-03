//
//  KAudioBox.h
//  framework
//
//  Created by iwind on 5/4/09.
//  Copyright 2009 Bokan Tech. All rights reserved.
//

#import "kitchen_init.h"

#ifdef KITCHEN_AV_ENABLED

#import <Foundation/Foundation.h>

@class KAudio, KAudioPlayer;

@interface KAudioBox : NSObject {
	NSMutableDictionary *players;
}

- (KAudioPlayer *) add:(KAudioPlayer *)player forKey:(NSString *) key;
- (void) play:(NSString *) key;
- (void) stop:(NSString *) key;
- (void) remove:(NSString *) key;

/** play all players **/
- (void) play;

/** stop all players **/
- (void) stop;

/** pause all players **/
- (void) pause;

- (KAudioPlayer *) playerForKey:(NSString *) key;
- (KAudioPlayer *) addAudioNamed:(NSString *)name forKey:(NSString *) key;

/** mute **/
- (void) setMute;

/** just mute a player who is identified by the key **/
- (void) setMute:(NSString *) key;

@end

#endif