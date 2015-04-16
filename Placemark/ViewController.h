//
//  ViewController.h
//  Placemark
//
//  Created by James Yanyuk on 4/11/15.
//  Copyright (c) 2015 placemark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MetaioSDK/MetaioSDKViewController.h>

//Added
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <metaioSDK/IMetaioSDK.h> //find where this is and wtf is does

//Added
namespace metaio
{
    class IGeometry;
}

@interface ViewController : MetaioSDKViewController <UITableViewDataSource, UITableViewDelegate>

{
    //Added pins
    metaio::IAnnotatedGeometriesGroup* annotatedGeometriesGroup;
    metaio::IGeometry* londonGeo;
    metaio::IGeometry* romeGeo;
    metaio::IGeometry* parisGeo;
    metaio::IGeometry* tokyoGeo;
    metaio::IGeometry* metaioMan;
    metaio::IRadar* m_radar;
    
    metaio::LLACoordinate   m_currentLocation;
}

- (metaio::IGeometry*)loadUpdatedAnnotation:(metaio::IGeometry*)geometry userData:(void*)userData existingAnnotation:(metaio::IGeometry*)existingAnnotation;

//@property (strong, nonatomic) NSArray *locationResults;

@property (strong, nonatomic) NSMutableArray *locationResults;

@property (strong, nonatomic) UITextField *searchTextField;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet GLKView *glView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;


-(void)hideSearchResults:(BOOL)hiddenState;


@end

