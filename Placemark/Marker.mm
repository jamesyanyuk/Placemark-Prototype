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
@synthesize geo;
@synthesize geoObj;

+ (id)createMarker:(NSString*)nameD rating:(NSString*)rating geo:(metaio::LLACoordinate)geo {
    Marker *newMarker = [[self alloc] init];
    newMarker.nameD = nameD;
    newMarker.rating = rating;
    newMarker.geo = geo;
    return newMarker;
}

- (void)addGeoObject:(metaio::IGeometry*)geoObject {
    self.geoObj = geoObject;
}

@end