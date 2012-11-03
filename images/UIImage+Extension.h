//
//  UIImage+Extension.h
//  TestTransform
//
//  Created by LiuXiangChao on 8/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "kitchen_init.h"

#ifdef KITCHEN_CORE_MEDIA_ENABLED
#import <CoreMedia/CoreMedia.h>
#endif

@interface UIImage (Extension)

#ifdef KITCHEN_CORE_MEDIA_ENABLED
- (UIImage *) initWithSampleBuffer:(CMSampleBufferRef) sampleBuffer;
#endif

- (UIImage *) blur:(NSUInteger)radius;

- (UIImage *) rotateWithOrientation:(UIInterfaceOrientation) orientation;
- (UIImage *) fixOrientation;

@end
