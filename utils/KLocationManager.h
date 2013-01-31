//
//  KLocationManager.h
//  TestTransform
//
//  Created by LiuXiangChao on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "kitchen_init.h"

#ifdef KITCHEN_CORE_LOCATION_ENABLED

#import <Foundation/Foundation.h>
#import "KLocationManagerDelegate.h"
#import <CoreLocation/CoreLocation.h>

@interface KLocationManager : NSObject <CLLocationManagerDelegate> {
@private
    CLLocationManager *_locationManager;
    
}


@property (nonatomic) id<KLocationManagerDelegate> delegate;
@property (nonatomic) KLocationManagerGPSSignalStrength signalStrength;
@property (nonatomic, setter = setAccuracy:) CLLocationAccuracy accuracy; 
@property (nonatomic, setter = setDistanceFilter:) CLLocationDistance distanceFilter;
@property (nonatomic, setter = setHeadingFilter:) CLLocationDegrees headingFilter;
@property (nonatomic) BOOL isRunning;

+ (KLocationManager *)defaultLocationManager;
- (CLLocation *) location;
- (void) start;
- (void) stop;
- (void) stopUpdatingLocation;
- (void) stopUpdatingHeading;

@end

#endif
