//
//  KLocationManagerDelegate.h
//  TestTransform
//
//  Created by LiuXiangChao on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@class KLocationManager;

typedef enum {
    KLocationManagerGPSSignalStrengthInvalid = 0
    , KLocationManagerGPSSignalStrengthWeak
    , KLocationManagerGPSSignalStrengthMiddle
    , KLocationManagerGPSSignalStrengthStrong
} KLocationManagerGPSSignalStrength;

@protocol KLocationManagerDelegate <NSObject>

@optional
- (void)locationManager:(KLocationManager *)locationManager signalStrengthChanged:(KLocationManagerGPSSignalStrength)signalStrength;
- (void)locationManager:(KLocationManager *)locationManager from:(CLLocation *) oldLocation to:(CLLocation *) newLocation;
- (void)locationManager:(KLocationManager *)locationManager didUpdateHeading:(CLHeading *) heading;

@end
