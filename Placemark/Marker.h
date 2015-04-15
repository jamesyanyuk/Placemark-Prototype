//
//  Marker.h
//  Placemark
//
//  Created by James Yanyuk on 4/11/15.
//  Copyright (c) 2015 placemark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Marker : NSObject {
    NSString *nameD;
    NSString *rating;
    NSString *latitude;
    NSString *longitude;
}

@property (nonatomic, copy) NSString *nameD;
@property (nonatomic, copy) NSString *rating;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *longitude;

+ (id)createMarker:(NSString*)nameD rating:(NSString*)rating latitude:(NSString *)latitude longitude:(NSString *)longitude;

@end