//
//  TripLocation.m
//  Placemark
//
//  Created by Catherine Feldman on 4/11/15.
//  Copyright (c) 2015 placemark. All rights reserved.
//

#import "TripLocation.h"

@implementation TripLocation

@synthesize location;
@synthesize desc;


+ (id)createTripLocation:(NSString *)location desc:(NSString *)desc
{
TripLocation *newTripLocation = [[self alloc] init];
newTripLocation.location = location;
newTripLocation.desc = desc;
return newTripLocation;
}

@end
