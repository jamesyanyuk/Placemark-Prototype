//
//  Marker.h
//  Placemark
//
//  Created by James Yanyuk on 4/11/15.
//  Copyright (c) 2015 placemark. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Marker : NSObject {
    NSString *location;
    NSString *desc;
}

@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *desc;

+ (id)createMarker:(NSString*)location desc:(NSString*)desc;

@end