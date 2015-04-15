//
//  TripLocation.h
//  Placemark
//
//  Created by Catherine Feldman on 4/11/15.
//  Copyright (c) 2015 placemark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TripLocation : NSObject{
    NSString *location;
    NSString *desc;
}

@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *desc;

+ (id)createTripLocation:(NSString*)location desc:(NSString*)desc;


@end
