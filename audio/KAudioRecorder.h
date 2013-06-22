//
//  KAudioRecorder.h
//  Ditalk
//
//  Created by Liu Xiangchao on 6/18/13.
//  Copyright (c) 2013 YUN4S. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@protocol KAudioRecorderDelegate;

@interface KAudioRecorder : NSObject  <AVAudioRecorderDelegate> {
@private
    AVAudioRecorder *_recorder;
    NSTimer *_powerTimer;
    
    BOOL _isCanceling;
    
    NSTimeInterval _startTime;
    NSTimeInterval _duration;
    NSString *_filename;
}

@property(nonatomic) id<KAudioRecorderDelegate> delegate;

+ (KAudioRecorder *) defaultRecorder;
- (void) start;
- (void) stop;
- (BOOL) isRecording;
- (NSTimeInterval) duration;
- (NSString *) filename;

@end

@protocol KAudioRecorderDelegate <NSObject>

@optional
- (void) audioRecorderDidFinish:(KAudioRecorder *) recorder path:(NSString *) path success:(BOOL) success;
- (void) audioRecorderPowerDidChange:(KAudioRecorder *) recorder power:(float) power;

@end