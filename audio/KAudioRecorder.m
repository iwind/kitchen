//
//  KAudioRecorder.m
//  Ditalk
//
//  Created by Liu Xiangchao on 6/18/13.
//  Copyright (c) 2013 YUN4S. All rights reserved.
//

#import "KAudioRecorder.h"
#import "KApp.h"

@implementation KAudioRecorder

@synthesize delegate;

+ (KAudioRecorder *) defaultRecorder {
    static KAudioRecorder *instance = nil;
    if (instance == nil) {
        instance = [[self alloc] init];
    }
    return instance;
}

- (id) init {
    if (self = [super init]) {
        NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                  [NSNumber numberWithFloat:16000.0], AVSampleRateKey,
                                  [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                  nil];
        NSError *error = nil;
        NSURL *fileURL = [NSURL fileURLWithPath:[[KApp defaultApp] tmpPathFor:@"recorder.m4a"]];
        _recorder = [[AVAudioRecorder alloc] initWithURL:fileURL settings:settings error:&error];
        _recorder.delegate = self;
        _recorder.meteringEnabled = YES;
        [_recorder prepareToRecord];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doStopNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void) start {
    if ([_recorder isRecording]) {
        [self stop];
    }
    
    _startTime = [[NSDate date] timeIntervalSince1970];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    [session setCategory:AVAudioSessionCategoryRecord error:nil];
    [session setActive:YES error:nil];
    
    [_recorder record];
    
    _powerTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updatePowerTimer:) userInfo:nil repeats:YES];
}

- (void) stop {
    _duration = [[NSDate date] timeIntervalSince1970] - _startTime;
    
    [_powerTimer invalidate];
    _powerTimer = nil;
    
    [_recorder stop];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
}

- (BOOL) isRecording {
    return _recorder.isRecording;
}

- (NSTimeInterval) duration {
    return _duration;
}

- (NSString *) filename {
    return _filename;
}

- (void) updatePowerTimer:(NSTimer *) timer {
    [_recorder updateMeters];
    float power = [_recorder peakPowerForChannel:0];
    if (power >= 0.0) {
        power = 1.0;
    }
    else {
        if (power < -50.0) {
            power = -50.0;
        }
        power = (50.0 + power)/50.0;
    }
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(audioRecorderPowerDidChange:power:)]) {
        [self.delegate audioRecorderPowerDidChange:self power:power];
    }
}

- (void) doStopNotification:(NSNotification *) notification {
    _isCanceling = YES;
    
    if ([_recorder isRecording]) {
        [self stop];
        [_recorder deleteRecording];
    }
}

#pragma mark Recorder Delegate
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (_isCanceling) {
        _isCanceling = NO;
        
        flag = NO;
    }
    
    _filename = nil;
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(audioRecorderDidFinish:path:success:)]) {
        NSString *newPath = nil;
        if (flag) {
            //修改文件名
            _filename = [NSString stringWithFormat:@"recorder-%f.m4a", [[NSDate date] timeIntervalSince1970]];
            NSString *oldPath = [[KApp defaultApp] tmpPathFor:@"recorder.m4a"];
            newPath = [[KApp defaultApp] tmpPathFor:_filename];
            if ([[NSFileManager defaultManager] fileExistsAtPath:oldPath]) {
                [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:nil];
            }
        }
        
        [self.delegate audioRecorderDidFinish:self path:newPath success:flag];
    }
}



@end
