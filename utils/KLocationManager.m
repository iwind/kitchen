//
//  KLocationManager.m
//  TestTransform
//
//  Created by LiuXiangChao on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KLocationManager.h"

#ifdef KITCHEN_CORE_LOCATION_ENABLED

@interface KLocationManager ()


@end


@implementation KLocationManager

@synthesize delegate, signalStrength, accuracy, distanceFilter, headingFilter, isRunning;

+ (id)defaultLocationManager {
    static KLocationManager *instance = nil;
    if (instance == nil) {
        instance = [[self alloc] init];
    }
    return instance;
}

- (id)init {
    if ((self = [super init])) {
        if ([CLLocationManager locationServicesEnabled]) {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.delegate = self;
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        }
        
        self.signalStrength = KLocationManagerGPSSignalStrengthInvalid;
    }
    
    return self;
}

- (CLLocation *) location {
    return _locationManager.location;
}

- (void) setAccuracy:(CLLocationAccuracy) _accuracy {
    accuracy = _accuracy;
    _locationManager.desiredAccuracy = _accuracy;
}

- (void) setDistanceFilter:(CLLocationDistance) _distanceFilter {
    distanceFilter = _distanceFilter;
    _locationManager.distanceFilter = _distanceFilter;
}

- (void) setHeadingFilter:(CLLocationDegrees) _headingFilter {
    headingFilter = _headingFilter;
    _locationManager.headingFilter = _headingFilter;
}

- (void) updateSignalStrenghth:(KLocationManagerGPSSignalStrength) strength {
    if (self.signalStrength == strength) {
        return;
    }
    self.signalStrength = strength;
    
    if ([self.delegate respondsToSelector:@selector(locationManager:signalStrengthChanged:)]) {
        [self.delegate locationManager:self signalStrengthChanged:strength];
    }
}

- (void) start {
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
    self.isRunning = YES;
}

- (void) stop {
    [_locationManager stopUpdatingLocation];
    [_locationManager stopUpdatingHeading];
    self.isRunning = NO;
}

- (void) stopUpdatingLocation {
    [_locationManager stopUpdatingLocation];
    self.isRunning = NO;
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    if (newLocation.horizontalAccuracy < 0 || oldLocation.horizontalAccuracy < 0) {
        [self updateSignalStrenghth:KLocationManagerGPSSignalStrengthInvalid];
        return;
    }
    
    //信号
    if (newLocation.horizontalAccuracy < 20) {
        [self updateSignalStrenghth:KLocationManagerGPSSignalStrengthStrong];
    }
    else if (newLocation.horizontalAccuracy < 70.0) {
        [self updateSignalStrenghth:KLocationManagerGPSSignalStrengthMiddle];
    }
    else {
        [self updateSignalStrenghth:KLocationManagerGPSSignalStrengthWeak];
    }
    
    
    if ([self.delegate respondsToSelector:@selector(locationManager:from:to:)]) {
        [self.delegate locationManager:self from:oldLocation to:newLocation];
    }
}

- (void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if ([self.delegate respondsToSelector:@selector(locationManager:didUpdateHeading:)]) {
        [self.delegate locationManager:self didUpdateHeading:newHeading];
    }
}

- (void)dealloc {
    [_locationManager stopUpdatingLocation];
    [_locationManager stopUpdatingHeading];
    _locationManager = nil;
}


@end

#endif