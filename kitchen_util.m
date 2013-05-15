/*
 *  kitchen_util.c
 *  framework
 *
 *  Created by iwind on 6/2/09.
 *  Copyright 2009 Bokan Tech. All rights reserved.
 *
 */

#import "kitchen_init.h"
#include "kitchen_util.h"
#import "KRandom.h"
#import "md5.h"

void KLog(NSString * format, ...) {
#ifdef _DEBUG
	va_list args;
	va_start(args, format);	
	NSLogv([@"[kitchen]" stringByAppendingString: format], args);
#endif	
}

CGPoint KGLCoordinate(CGRect rect, CGRect envRect) {
	return CGPointMake(rect.origin.x - envRect.origin.x, envRect.origin.y + envRect.size.height - rect.origin.y - rect.size.height);
}

int KRand(int min, int max) {
	return [KRandom randBetweenMin:min max:max];
}

id o(id options, NSString *key) {
	NSArray *keys = [key componentsSeparatedByString:@"."];
	for (NSString *_key in keys) {
		if ([options isKindOfClass:[NSArray class]]) {
			int _intKey = [_key intValue];
			if ([(NSArray *) options count] > _intKey) {
				options = [(NSArray *) options objectAtIndex:_intKey];
			}
			else {
				return nil;
			}
		}
		else if ([options isKindOfClass:[NSDictionary class]]) {
			options = [(NSDictionary *) options objectForKey:_key];
		}
	}
	return options;
}

NSString *KMd5(NSString * string) {
	MD5_CTX mdContext;
	const char *inString = [string UTF8String];
	unsigned int len = strlen (inString);
	
	MD5Init (&mdContext);
	MD5Update (&mdContext, inString, len);
	MD5Final (&mdContext);
	
	return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", 
			mdContext.digest[0], mdContext.digest[1], mdContext.digest[2], mdContext.digest[3], 
			mdContext.digest[4], mdContext.digest[5], mdContext.digest[6], mdContext.digest[7],
			mdContext.digest[8], mdContext.digest[9], mdContext.digest[10], mdContext.digest[11],
			mdContext.digest[12], mdContext.digest[13], mdContext.digest[14], mdContext.digest[15]];
}

long KCRC32(NSString *string) {
    uint32_t crc = crc32(0L, NULL, 0);
    crc = crc32(crc, [string UTF8String], [string length]);
    return crc;
}


/** copy from http://www.gotow.net/creative/wordpress/?p=7 **/
CGImageRef KCGImageScale(CGImageRef image, float scale) {
    // Create the bitmap context
    CGContextRef    context = NULL;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    int width = CGImageGetWidth(image) * scale;
    int height = CGImageGetHeight(image) * scale;
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (width * 4);
    bitmapByteCount     = (bitmapBytesPerRow * height);
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        return nil;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    CGColorSpaceRef colorspace = CGImageGetColorSpace(image);
    context = CGBitmapContextCreate (bitmapData,width,height,8,bitmapBytesPerRow,
                                     colorspace,kCGImageAlphaNoneSkipFirst);
    CGColorSpaceRelease(colorspace);
    
    if (context == NULL)
        // error creating context
        return nil;
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(context, CGRectMake(0,0,width, height), image);
    
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    free(bitmapData);
    
    return imgRef;
}

CGImageRef KCGImageScaleToSize(CGImageRef image, float width, float height, BOOL fit) {
    float oriWidth = CGImageGetWidth(image);
    float oriHeight = CGImageGetHeight(image);
    
    float ratio = 1.0;
    if (fit) {
        if (oriWidth/oriHeight > width/height) {
            ratio = width/oriWidth;
        }
        else {
            ratio = height/oriHeight;
        }
    }
    else {
        if (oriWidth/oriHeight > width/height) {
            ratio = height/oriHeight;
            float newWidth = width / ratio;
            image = CGImageCreateWithImageInRect(image, CGRectMake((oriWidth - newWidth)/2, 0.0, newWidth, oriHeight));
        }
        else {
            ratio = width/oriWidth;
            float newHeight = height / ratio;
            image = CGImageCreateWithImageInRect(image, CGRectMake(0.0, (oriHeight - newHeight)/2, oriWidth, newHeight));
        }
    }
    
    return KCGImageScale(image, ratio);
}

CGImageRef KCGImageRotate(CGImageRef image, float angle) {
    CGFloat angleInRadians = angle * (M_PI / 180);
	CGFloat width = CGImageGetWidth(image);
	CGFloat height = CGImageGetHeight(image);
    
	CGRect imgRect = CGRectMake(0, 0, width, height);
	CGAffineTransform transform = CGAffineTransformMakeRotation(angleInRadians);
	CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, transform);
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef bmContext = CGBitmapContextCreate(NULL,
												   rotatedRect.size.width,
												   rotatedRect.size.height,
												   8,
												   0,
												   colorSpace,
												   kCGImageAlphaPremultipliedFirst);
	CGContextSetAllowsAntialiasing(bmContext, YES);
	CGContextSetInterpolationQuality(bmContext, kCGInterpolationHigh);
	CGColorSpaceRelease(colorSpace);
	CGContextTranslateCTM(bmContext,
						  +(rotatedRect.size.width/2),
						  +(rotatedRect.size.height/2));
	CGContextRotateCTM(bmContext, angleInRadians);
	CGContextDrawImage(bmContext, CGRectMake(-width/2, -height/2, width, height),
					   image);
    
	CGImageRef rotatedImage = CGBitmapContextCreateImage(bmContext);
	CFRelease(bmContext);
    
	return rotatedImage;
}

double KDegreesToRadians(double degrees) {
    return degrees * M_PI / 180.0;
}

double KRadiansToDegrees(double radians) {
    return radians * 180.0/M_PI;
}

void KAvaragePoints(CGPoint points[], CGPoint resultPoints[], float *newMinX, float *newMaxX, float *newMinY, float *newMaxY, int count, int size, float dx, float dy) {
    float avgXValue = 0;
    float xs[size];
    int xIndex = 0;
    int avgXCount = 0;
    
    float avgYValue = 0;
    float ys[size];
    int yIndex = 0;
    int avgYCount = 0;
    
    int maxValues = size;
    
    //初始化xs & ys
    for (int i = 0; i < size; i ++) {
        xs[i] = 0.0;
        ys[i] = 0.0;
    }
    
    CGPoint firstPoint = points[0];
    *newMinX = firstPoint.x;
    *newMaxX = firstPoint.x;
    *newMinY = firstPoint.y;
    *newMaxY = firstPoint.y;
    for (int i = 0; i < count; i ++) {
        CGPoint point = points[i];
        float px = point.x + dx;
        float py = point.y + dy;
        
        //取平均值，路程应该是向前的
        float totalX;
        if (avgXCount > 0) {
            totalX = (avgXValue * avgXCount - xs[xIndex] + px);
        }
        else {
            totalX = px;
        }
        
        //在数组中设置新值
        xs[xIndex] = px;
        xIndex ++;
        if (xIndex >= maxValues) {
            xIndex = 0;
        }
        if (avgXCount < maxValues) {
            avgXCount ++;
        }
        avgXValue = totalX/avgXCount;
        
        float totalY;
        if (avgYCount > 0) {
            totalY = (avgYValue * avgYCount - ys[yIndex] + py);
        }
        else {
            totalY = py;
        }
        
        //在数组中设置新值
        ys[yIndex] = py;
        yIndex ++;
        if (yIndex >= maxValues) {
            yIndex = 0;
        }
        if (avgYCount < maxValues) {
            avgYCount ++;
        }
        avgYValue = totalY/avgYCount;
        
        //比较大小
        if (avgXValue < *newMinX) {
            *newMinX = avgXValue;
        }
        if (avgXValue > *newMaxX) {
            *newMaxX = avgXValue;
        }
        if (avgYValue < *newMinY) {
            *newMinY = avgYValue;
        }
        if (avgYValue > *newMaxY) {
            *newMaxY = avgYValue;
        }
        
        resultPoints[i] = CGPointMake(avgXValue, avgYValue);
    }
}

double KMapLonToPixel(double lon, int zoom) {
    return (lon + 180) * (256 << zoom)/360;
}

double KMapPixelToLon(double pixelX, int zoom) {
    return pixelX * 360/(256 << zoom)-180;
}

double KMapLatToPixel(double lat, int zoom) {
    double sinY = sin(lat * M_PI / 180);
    double y = log((1+ sinY)/(1-sinY));
    return (128 << zoom)*(1-y/(2*M_PI));
}
//像素Y到纬度
double KMapPixelToLat(double pixelY, int zoom) {
    double y = 2 * M_PI *(1 - pixelY /(128 << zoom));
    double z = pow(M_E, y);
    double sinY = (z -1)/(z +1);
    return asin(sinY) * 180/M_PI;
}

float KMapBearingFromPoints(CGPoint startPoint, CGPoint destinationPoint) {
    float x = destinationPoint.x - startPoint.x;
    float y = destinationPoint.y - startPoint.y;
    float r = powf(powf(x, 2.0) + powf(y, 2.0), 0.5);
    float bearing = asinf(x/r);
    if (y <= 0) {
        if (bearing >= 0) {
            return bearing;
        }
        return M_PI * 2 + bearing;
    }
    
    return M_PI - bearing;
}

NSString *KUUID() {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return [[uuidStr stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
}