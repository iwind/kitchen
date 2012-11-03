//
//  KImageAnimation.m
//  TestTransform
//
//  Created by LiuXiangChao on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KImageAnimation.h"

@interface KImageAnimation()

- (void) runTimer:(NSTimer *) timer;

@end

@implementation KImageAnimation

@synthesize repeatCount, duration;

- (id) initWithImageView:(UIImageView *) imageView {
    if (self = [super init]){
        _index = 0;
        _images = [[NSMutableArray alloc] init];
        _imageView = imageView;
        _isRunning = NO;
        _repeats = 0;
        
        self.repeatCount = 0;
        self.duration = 1.0;
    }
    return self;
}

- (void) addImages:(NSArray *) images {
    for (UIImage *image in images) {
        [_images addObject:image];
    }
}

- (void) start {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    if (self.duration <= 0) {
        return;
    }
    _index = 0;
    _repeats = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:self.duration target:self selector:@selector(runTimer:) userInfo:nil repeats:YES];
}

- (void) stop {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _index = 0;
    _repeats = 0;
    _isRunning = NO;
}

- (void) pause {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _isRunning = NO;
}

- (void) resume {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:self.duration target:self selector:@selector(runTimer:) userInfo:nil repeats:YES];
}

- (BOOL) isAnimating {
    return _isRunning;
}

- (void) runTimer:(NSTimer *) timer {
    if (self.repeatCount > 0 && _repeats > self.repeatCount) {
        _isRunning = NO;
        
        [_timer invalidate];
        _timer = nil;
        return;
    }
    
    _isRunning = YES;
    _repeats ++;
    
    if (_index >= _images.count) {
        _index = 0;
    }
    
    _imageView.image = [_images objectAtIndex:_index];
    
    //增长
    _index ++;
    if (_index >= _images.count) {
        _index = 0;
    }
}

@end
