//
//  KAudioBox.m
//  framework
//
//  Created by iwind on 5/4/09.
//  Copyright 2009 Bokan Tech. All rights reserved.
//

#import "KAudioBox.h"
#import "kitchen_util.h"
#import "KAudioPlayer.h"

#ifdef KITCHEN_AV_ENABLED

@implementation KAudioBox

- (id) init {
	players = [[NSMutableDictionary alloc] init];
	return [super init];
}

- (KAudioPlayer *) add:(KAudioPlayer *)player forKey:(NSString *) key {
	KAudioPlayer *_player = [self playerForKey:key];
	if (_player != nil) {
		if ([_player isPlaying]) {
			[_player stop];
		}
	}
	[player setKey:key];
	[players setObject:player forKey:key];
	return player;
}

- (void) play:(NSString *) key {
	[[self playerForKey:key] play];
}

- (void) prepare:(NSString *) key {
    [[self playerForKey:key] prepareToPlay];
}

- (void) play {
    for (KAudioPlayer *player in [players allValues]) {
		if (![player isPlaying]) {
			[player play];
		}
	}
}

- (void) remove:(NSString *) key {
	KAudioPlayer *player = [self playerForKey:key];
	if (player != nil) {
		if ([player isPlaying]) {
			[player stop];
		}
		[players removeObjectForKey:key];
	}
}

- (void) stop:(NSString *) key {
	[[self playerForKey:key] stop];
}

- (void) stop {
	for (KAudioPlayer *player in [players allValues]) {
		if ([player isPlaying]) {
			[player stop];
		}
	}
}

- (void) pause {
	for (KAudioPlayer *player in [players allValues]) {
		if ([player isPlaying]) {
			[player pause];
		}
	}
}

- (KAudioPlayer *) playerForKey:(NSString *) key {
	return (KAudioPlayer *) [players objectForKey:key];
}

- (KAudioPlayer *) addAudioNamed:(NSString *)name forKey:(NSString *) key {
	NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@""];
    if (path == nil) {//找不到文件
        return nil;
    }
    
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: path];
    NSError *error;
	KAudioPlayer *player = [[KAudioPlayer alloc] initWithContentsOfURL: fileURL  error:&error];
    if (error) {
        return nil;
    }
	[self add:player forKey:key];
	return player;
}

- (void) setMute {
	for (KAudioPlayer *player in [players allValues]) {
		[player stop];
		[player setVolume:0];
	}
}

- (void) setMute:(NSString *) key {
	KAudioPlayer *player = [self playerForKey:key];
	if (player != nil) {
		[player stop];
		[player setVolume:0];
	}
}

@end


#endif