//
//  TCameraSession.h
//  ZhiTiao
//
//  Created by LiuXiangChao on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "kitchen_init.h"

#import <UIKit/UIKit.h>

#ifdef KITCHEN_CORE_MEDIA_ENABLED

#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

@protocol KCameraDelegate;

@interface KCamera : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {

}

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layer;
@property (nonatomic) NSString *preset;
@property (nonatomic) int frames;
@property (nonatomic) id<KCameraDelegate> delegate;

+ (id) defaultCamera;

- (void) drawInView:(UIView *) container;
- (BOOL) isRunning;
- (void) start;
- (void) stop;
- (void) focus:(CGPoint) point;

@end

@protocol KCameraDelegate <NSObject>

@optional
- (void) camera:(KCamera *) camera buffer:(CMSampleBufferRef) buffer;

@end

#endif