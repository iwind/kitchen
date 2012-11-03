//
//  KImageAnimation.h
//  TestTransform
//
//  Created by LiuXiangChao on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KImageAnimation : NSObject {
@private
    int _index;
    int _repeats;
    
    NSMutableArray *_images;
    UIImageView *_imageView;
    BOOL _isRunning;
    NSTimer *_timer;
}

@property (nonatomic) int repeatCount;
@property (nonatomic) float duration;

- (id) initWithImageView:(UIImageView *) imageView;
- (void) addImages:(NSArray *) images;
- (void) start;
- (void) stop;
- (void) pause;
- (void) resume;
- (BOOL) isAnimating;

@end
