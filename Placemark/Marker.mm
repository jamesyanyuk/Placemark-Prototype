//
//  Marker.m
//  Placemark
//
//  Created by James Yanyuk on 4/11/15.
//  Copyright (c) 2015 placemark. All rights reserved.
//

#import "Marker.h"

@implementation Marker
@synthesize location;
@synthesize desc;

+ (id)createMarker:(NSString *)location desc:(NSString *)desc
{
    Marker *newMarker = [[self alloc] init];
    newMarker.location = location;
    newMarker.desc = desc;
    return newMarker;
}

@end