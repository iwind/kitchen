/*
 *  kitchen_util.h
 *  framework
 *
 *  Created by iwind on 6/2/09.
 *  Copyright 2012 Ometworks Tech. All rights reserved.
 *
 */
#ifndef KITCHEN_UTIL_H
#define KITCHEN_UTIL_H

#import "crc.h"

/** define kByte type **/
typedef unsigned char kByte;

/** output log into console, valid just when _DEBUG is setted **/
void KLog(NSString * format, ...);

/** convert coordinate from CG coordinate to OpenGL coordinate **/
CGPoint KGLCoordinate(CGRect rect, CGRect envRect);

/** get a random number who is between min and max **/
int KRand(int min, int max);

/** get value for key in an array or a dictionary options **/
id o(id options, NSString *key);

/** calculate md5 of a string **/
NSString *KMd5(NSString * string);
long KCRC32(NSString *string);

/** 图片相关 **/
CGImageRef KCGImageScale(CGImageRef image, float scale);
CGImageRef KCGImageScaleToSize(CGImageRef image, float width, float height, BOOL fit);
CGImageRef KCGImageRotate(CGImageRef image, float angle);

/** 数学相关 **/
double KDegreesToRadians(double degrees);
double KRadiansToDegrees(double radians);
void KAvaragePoints(CGPoint points[], CGPoint resultPoints[], float *newMinX, float *newMaxX, float *newMinY, float *newMaxY, int count, int size, float dx, float dy);//size:聚合的数量

/** 地理位置 **/
double KMapLonToPixel(double lon, int zoom);
double KMapPixelToLon(double pixelX, int zoom);
double KMapLatToPixel(double lat, int zoom);
double KMapPixelToLat(double pixelY, int zoom);
float KMapBearingFromPoints(CGPoint startPoint, CGPoint destinationPoint);

/** 杂项 **/
NSString *KUUID();

#endif