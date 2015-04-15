//
//  Marker.m
//  Placemark
//
//  Created by James Yanyuk on 4/11/15.
//  Copyright (c) 2015 placemark. All rights reserved.
//

#import "Marker.h"

@implementation Marker

@synthesize nameD;
@synthesize rating;
@synthesize latitude;
@synthesize longitude;

+ (id)createMarker:(NSString*)nameD rating:(NSString*)rating latitude:(NSString *)latitude longitude:(NSString *)longitude {
    Marker *newMarker = [[self alloc] init];
    newMarker.nameD = nameD;
    newMarker.rating = rating;
    newMarker.latitude = latitude;
    newMarker.longitude = longitude;
    return newMarker;
}

@end