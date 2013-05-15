//
//  CLLocation+Extension.m
//  ZhiTiao
//
//  Created by LiuXiangChao on 8/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CLLocation+Extension.h"
#import "kitchen.h"
#import "BMapKit.h"

@implementation CLLocation (Extension)

- (CLLocationDegrees) degreesWithLocation:(CLLocation *) location {
    double lat1 = KDegreesToRadians(self.coordinate.latitude);
    double lon1 = KDegreesToRadians(self.coordinate.longitude);
    
    double lat2 = KDegreesToRadians(location.coordinate.latitude);
    double lon2 = KDegreesToRadians(location.coordinate.longitude);
    
    double dLon = lon2 - lon1;
    
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double radiansBearing = atan2(y, x);
    if (radiansBearing < 0) {
        radiansBearing += 2 * M_PI;
    }
    
    return KRadiansToDegrees(radiansBearing);
}

- (CLLocationCoordinate2D) baiduCoordinate {
    return BMKCoorDictionaryDecode(BMKBaiduCoorForWgs84(self.coordinate));
}

- (CLLocation *) baiduLocation {
    CLLocationCoordinate2D _coordinate = self.coordinate;
    return [[CLLocation alloc] initWithLatitude:_coordinate.latitude longitude:_coordinate.longitude];
}

/*
 * Refered from http://www.movable-type.co.uk/scripts/latlong.html
 */
- (CLLocation *) locationWithDistance:(CLLocationDistance) distance bearing:(CLLocationDegrees) bearing {
    double dist = distance * 0.9/CLLocationEarthRadius;
    
    CLLocationDegrees lat1 = KDegreesToRadians(self.coordinate.latitude);
    CLLocationDegrees lon1 = KDegreesToRadians(self.coordinate.longitude);
    CLLocationDegrees lat2 = KRadiansToDegrees(asin(sin(lat1) * cos(dist) +
                         cos(lat1) * sin(dist) * cos(bearing)));
    CLLocationDegrees lon2 = KRadiansToDegrees(lon1 + atan2(sin(bearing) * sin(dist) * cos(lat1),
                                 cos(dist) - sin(lat1) * sin(lat2)));
    return [[CLLocation alloc] initWithLatitude:lat2 longitude:lon2];
}

- (CLLocationDistance) distanceWithLocation:(CLLocation *) location {
    double lat1 = KDegreesToRadians(self.coordinate.latitude);
    double lon1 = KDegreesToRadians(self.coordinate.longitude);
    double lat2 = KDegreesToRadians(location.coordinate.latitude);
    double lon2 = KDegreesToRadians(location.coordinate.longitude);
    
    double distance = acos(sin(lat1) * sin(lat2) + cos(lat1) * cos(lat2) * cos(lon2 - lon1)) * CLLocationEarthRadius;
    return distance;
}

@end
