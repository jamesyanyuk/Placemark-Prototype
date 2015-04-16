//
//  Marker.h
//  Placemark
//
//  Created by James Yanyuk on 4/11/15.
//  Copyright (c) 2015 placemark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <metaioSDK/IMetaioSDK.h>

@interface Marker : NSObject {
    NSString *nameD;
    NSString *rating;
    double latitude;
    double longitude;
    metaio::LLACoordinate geo;
    metaio::IGeometry *geoObj;
}

@property (nonatomic, copy) NSString *nameD;
@property (nonatomic, copy) NSString *rating;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic) metaio::LLACoordinate geo;
@property (nonatomic) metaio::IGeometry *geoObj;

+ (id)createMarker:(NSString*)nameD rating:(NSString*)rating geo:(metaio::LLACoordinate)geo;
- (void)addGeoObject:(metaio::IGeometry*)geoObject;

@end