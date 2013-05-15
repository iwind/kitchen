//
//  CLLocation+Extension.h
//  ZhiTiao
//
//  Created by LiuXiangChao on 8/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define CLLocationEarthRadius 6371000

@interface CLLocation(Extension)

- (CLLocationDegrees) degreesWithLocation:(CLLocation *) location;
- (CLLocationCoordinate2D) baiduCoordinate;
- (CLLocation *) baiduLocation;
- (CLLocation *) locationWithDistance:(CLLocationDistance) distance bearing:(CLLocationDegrees) bearing;
- (CLLocationDistance) distanceWithLocation:(CLLocation *) location;

@end
