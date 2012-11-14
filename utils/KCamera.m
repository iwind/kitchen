//
//  TCameraSession.m
//  ZhiTiao
//
//  Created by LiuXiangChao on 8/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KCamera.h"
#import "kitchen_util.h"

#ifdef KITCHEN_CORE_MEDIA_ENABLED

@implementation KCamera

@synthesize device, session, layer, preset, frames, delegate;

+ (id) defaultCamera {
    static id instance;
    if (!instance) {
        instance = [[KCamera alloc] init];
    }
    return instance;
}

- (id) init {
    if (self = [super init]) {
        self.preset = AVCaptureSessionPresetPhoto;
        self.frames = 20;
    }
    return self;
}

- (void) drawInView:(UIView *) container {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //预览
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = self.preset;
    
    //预览
    self.layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.layer.bounds = container.layer.bounds;
    self.layer.position = CGPointMake(CGRectGetMidX(container.layer.bounds), CGRectGetMidY(container.layer.bounds));
    [container.layer insertSublayer:self.layer atIndex:0];
    
    //输入
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (!input) {
        KLog(@"ERROR: trying to open camera: %@", error);
    }
    [self.session addInput:input];
    
    //输出
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    output.alwaysDiscardsLateVideoFrames = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0
    output.minFrameDuration = CMTimeMake(1, self.frames);
#endif
    [self.session addOutput:output];
    
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
    //dispatch_release(queue);
#endif
    
    output.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    //输出帧频控制
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
    AVCaptureConnection *connection = [output.connections objectAtIndex:0];
    [connection setVideoMinFrameDuration:CMTimeMake(1, self.frames)];
    [connection setVideoMaxFrameDuration:CMTimeMake(1, self.frames)];
#endif
    
    //开始摄取
    [self.session startRunning];

}

- (BOOL) isRunning {
    return self.session.isRunning;
}

- (void) start {
    if (self.session.isRunning) {
        return;
    }
    return [self.session startRunning];
}

- (void) stop {
    if (!self.session.isRunning) {
        return;
    }
    return [self.session stopRunning];
}

- (void) focus:(CGPoint) point {
    if (!self.device.isFocusPointOfInterestSupported) {
        return;
    }
    
    NSError *configError;
    if ([self.device lockForConfiguration:&configError]) {
        self.device.focusPointOfInterest = CGPointMake(point.x, point.y);
        [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        [self.device unlockForConfiguration];
    }
    else {
        // NSLog(@"lock configuration error:%@", configError);
    }
}

#pragma mark Video output
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection { 
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(camera:buffer:)]) {
        [self.delegate camera:self buffer:sampleBuffer];
    }
}

@end

#endif