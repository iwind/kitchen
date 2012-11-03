//
//  sqlite_func.h
//  TestTransform
//
//  Created by LiuXiangChao on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//本文件大部分代码来自：http://www.thismuchiknow.co.uk/?p=71


#ifndef TestTransform_sqlite_func_h
#define TestTransform_sqlite_func_h

#import "sqlite3.h"
#import "kitchen_util.h"

static void sqliteDistanceFunc(sqlite3_context *context, int argc, sqlite3_value **argv) {
    // check that we have four arguments (lat1, lon1, lat2, lon2)
    assert(argc == 4);
    // check that all four arguments are non-null
    if (sqlite3_value_type(argv[0]) == SQLITE_NULL || sqlite3_value_type(argv[1]) == SQLITE_NULL || sqlite3_value_type(argv[2]) == SQLITE_NULL || sqlite3_value_type(argv[3]) == SQLITE_NULL) {
        sqlite3_result_null(context);
        return;
    }
    // get the four argument values
    double lat1 = sqlite3_value_double(argv[0]);
    double lon1 = sqlite3_value_double(argv[1]);
    double lat2 = sqlite3_value_double(argv[2]);
    double lon2 = sqlite3_value_double(argv[3]);
    // convert lat1 and lat2 into radians now, to avoid doing it twice below
    double lat1rad = KDegreesToRadians(lat1);
    double lat2rad = KDegreesToRadians(lat2);
    double lon1rad = KDegreesToRadians(lon1);
    double lon2rad = KDegreesToRadians(lon2);
    // apply the spherical law of cosines to our latitudes and longitudes, and set the result appropriately
    // 6378.1 is the approximate radius of the earth in kilometres
    sqlite3_result_double(context, acos(sin(lat1rad) * sin(lat2rad) + cos(lat1rad) * cos(lat2rad) * cos(lon1rad - lon2rad)) * 6378137);
}

static void sqliteNearFunc(sqlite3_context *context, int argc, sqlite3_value **argv) {
    assert(argc == 8);
    double lat1 = KDegreesToRadians(sqlite3_value_double(argv[0]));
    double lon1 = KDegreesToRadians(sqlite3_value_double(argv[1]));
    double lat2 = KDegreesToRadians(sqlite3_value_double(argv[2]));
    double lon2 = KDegreesToRadians(sqlite3_value_double(argv[3]));
    double width = sqlite3_value_double(argv[4]);
    double height = sqlite3_value_double(argv[5]);
    double far = sqlite3_value_double(argv[6]);
    double measure = sqlite3_value_double(argv[7]);
    
    double distance = acos(sin(lat1) * sin(lat2) + cos(lat1) * cos(lat2) * cos(lon1 - lon2)) * 6378137;
    
    width = width * measure;
    height = height * measure;
    
    if (width < 1.0 || height < 1.0) {
        sqlite3_result_int(context, 0);
        return;
    }
    
    //角度
    double dLon = lon2 - lon1;
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double radiansBearing = atan2(y, x);
    if (radiansBearing < 0) {
        radiansBearing += 2 * M_PI;
    }
    
    double w1 = distance * sin(radiansBearing);
    double h1 = distance * cos(radiansBearing);
    
    if (fabs(w1) <= far || fabs(h1) <= far || fabs(height - h1) <= far || fabs(width + w1) <= far) {
        sqlite3_result_int(context, 1);
    }
    else {
        sqlite3_result_int(context, 0);
    }
}

#endif
