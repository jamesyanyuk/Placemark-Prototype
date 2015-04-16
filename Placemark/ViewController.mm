//
//  ViewController.m
//  Placemark
//
//  Created by James Yanyuk on 4/11/15.
//  Copyright (c) 2015 placemark. All rights reserved.
//

#import "ViewController.h"
#import "SearchBarDelegate.h"
#import "Marker.h"
//Added
#import <QuartzCore/QuartzCore.h>
#include <metaioSDK/Common/SensorsComponentIOS.h>
#include <metaioSDK/IMetaioSDKIOS.h>

//Added
class AnnotatedGeometriesGroupCallback : public metaio::IAnnotatedGeometriesGroupCallback
{
public:
    AnnotatedGeometriesGroupCallback(ViewController* _vc) : vc(_vc) {}
    
    virtual metaio::IGeometry* loadUpdatedAnnotation(metaio::IGeometry* geometry, void* userData, metaio::IGeometry* existingAnnotation) override
    {
    return [vc loadUpdatedAnnotation:geometry userData:userData existingAnnotation:existingAnnotation];
    }

    ViewController* vc;

};

@interface ViewController ()

@property (nonatomic, assign) AnnotatedGeometriesGroupCallback *annotatedGeometriesGroupCallback;
- (UIImage*)getAnnotationImageForTitle:(NSString*)title;
@end

@implementation ViewController

@synthesize locationResults;
@synthesize searchTextField;

@synthesize searchBar;
@synthesize tableView;
@synthesize glView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"Loaded results table view controller...");
    
    //Added
    if (!m_pMetaioSDK->setTrackingConfiguration("GPS"))
    {
        NSLog(@"Failed to set the tracking configuration");
    }
    
    annotatedGeometriesGroup = m_pMetaioSDK->createAnnotatedGeometriesGroup();
    self.annotatedGeometriesGroupCallback = new AnnotatedGeometriesGroupCallback(self);
    annotatedGeometriesGroup->registerCallback(self.annotatedGeometriesGroupCallback);
    
    // Clamp geometries' Z position to range [5000;200000] no matter how close or far they are away.
    // This influences minimum and maximum scaling of the geometries (easier for development).
    m_pMetaioSDK->setLLAObjectRenderingLimits(5, 200);
    
    // Set render frustum accordingly
    m_pMetaioSDK->setRendererClippingPlaneLimits(10, 220000);
    
   //Create LLA for known cities
    metaio::LLACoordinate munich = metaio::LLACoordinate(48.142573, 11.550321, 0, 0);
    metaio::LLACoordinate london = metaio::LLACoordinate(51.50661, -0.130463, 0, 0);
    metaio::LLACoordinate rome = metaio::LLACoordinate(41.90177, 12.45987, 0, 0);
    metaio::LLACoordinate paris = metaio::LLACoordinate(48.85658, 2.348671, 0, 0);
    metaio::LLACoordinate tokyo = metaio::LLACoordinate(42.390864, -72.525875, 0, 0);
    
    
    // Load some POIs. Each of them has the same shape at its geoposition. We pass a string
    // (const char*) to IAnnotatedGeometriesGroup::addGeometry so that we can use it as POI title
    // in the callback, in order to create an annotation image with the title on it.
    londonGeo = [self createPOIGeometry:london];
    annotatedGeometriesGroup->addGeometry(londonGeo, (void*)"London");
    
    parisGeo = [self createPOIGeometry:paris];
    annotatedGeometriesGroup->addGeometry(parisGeo, (void*)"Paris");
    
    romeGeo = [self createPOIGeometry:rome];
    annotatedGeometriesGroup->addGeometry(romeGeo, (void*)"Rome");
    
    tokyoGeo = [self createPOIGeometry:tokyo];
    annotatedGeometriesGroup->addGeometry(tokyoGeo, (void*)"Tokyo");

    // load a 3D model and put it in Munich
    //TODO: change so that all the locations are pins
    NSString* metaioManModel = [[NSBundle mainBundle] pathForResource:@"metaioman"
                                                               ofType:@"md2"
                                                          inDirectory:@"Assets"]; //CHANGED

    if (metaioManModel)
    {
        const char *utf8Path = [metaioManModel fileSystemRepresentation];
        metaioMan = m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
        metaioMan->setTranslationLLA(munich);
        metaioMan->setLLALimitsEnabled(true);
        metaioMan->setScale(500.f);
        //changed
         NSLog(@"Model found");
    }
    else
    {
        NSLog(@"Model not found");
    }
    
    // Create radar object
    m_radar = m_pMetaioSDK->createRadar();
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *assetFolder = @"../Assets"; //CHANGED
    NSString *radarPath = [mainBundle pathForResource:@"radar"
                                               ofType:@"png"
                                          inDirectory:assetFolder];
    const char *radarUtf8Path = [radarPath UTF8String];
    
    m_radar->setBackgroundTexture(metaio::Path::fromUTF8(radarUtf8Path));
    
    NSString *yellowPath = [mainBundle pathForResource:@"yellow"
                                                ofType:@"png"
                                           inDirectory:assetFolder];
    const char *yellowUtf8Path = [yellowPath UTF8String];
    m_radar->setObjectsDefaultTexture(metaio::Path::fromUTF8(yellowUtf8Path));
    m_radar->setRelativeToScreen(metaio::IGeometry::ANCHOR_TL);
    
    // Add geometries to the radar
    m_radar->add(londonGeo);
    m_radar->add(parisGeo);
    m_radar->add(romeGeo);
    m_radar->add(tokyoGeo);
    m_radar->add(metaioMan);
    
    
    
    
    //James lies below v
    locationResults = [[NSMutableArray alloc] init];
    
    [self.tableView reloadData];
    
    // Initially hide results table view
    [tableView setHidden:YES];
    
    UIView *subviews = [searchBar.subviews lastObject];
    searchTextField = (id)[subviews.subviews objectAtIndex:1];
    
    UITapGestureRecognizer *tapTableView = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(tapGestureHandler:)];
    
    UITapGestureRecognizer *tapGlView = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(tapGestureHandler:)];
    
    // Gesture recognizer for table view
    [tableView addGestureRecognizer:tapTableView];
    [tapTableView setCancelsTouchesInView:NO];
    
    // Gesture recognizer for gl view
    [glView addGestureRecognizer:tapGlView];
    [tapGlView setCancelsTouchesInView:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSearchResults) name:UITextFieldTextDidChangeNotification object:nil];
}

//Added

- (void)viewWillDisappear:(BOOL)animated
{
    // as soon as the view disappears, we stop rendering and stop the camera
    m_pMetaioSDK->stopCamera();
    [super viewWillDisappear:animated];
    
    annotatedGeometriesGroup->registerCallback(NULL);
    if (self.annotatedGeometriesGroupCallback) {
        delete self.annotatedGeometriesGroupCallback;
        self.annotatedGeometriesGroupCallback = NULL;
    }
}

//Added
- (void)drawFrame
{
    // make pins appear upright
    if (m_pMetaioSDK && m_pSensorsComponent)
    {
        const metaio::SensorValues sensorValues = m_pSensorsComponent->getSensorValues();
        
        float heading = 0.0f;
        if (sensorValues.hasAttitude())
        {
            float m[9];
            sensorValues.attitude.getRotationMatrix(m);
            
            metaio::Vector3d v(m[6], m[7], m[8]);
            v = v.getNormalized();
            
            heading = -atan2(v.y, v.x) - (float)M_PI_2;
        }
        
        metaio::IGeometry* geos[] = {londonGeo, parisGeo, romeGeo, tokyoGeo};
        const metaio::Rotation rot((float)M_PI_2, 0.0f, -heading);
        for (int i = 0; i < 4; ++i)
        {
            geos[i]->setRotation(rot);
        }
    }
    
    [super drawFrame];
}

//Added


#pragma mark - Handling Touches

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Here's how to pick a geometry
    UITouch *touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self.glkView];
    
    // get the scale factor (will be 2 for retina screens)
    float scale = self.glkView.contentScaleFactor;
    
    // ask sdk if the user picked an object
    // the 'true' flag tells sdk to actually use the vertices for a hit-test, instead of just the bounding box
    metaio::IGeometry* model = m_pMetaioSDK->getGeometryFromViewportCoordinates(loc.x * scale, loc.y * scale, true);
    
    if ( model )
    {
        metaio::LLACoordinate modelCoordinate = model->getTranslationLLA();
        NSLog(@"You picked a model at location %f, %f!", modelCoordinate.latitude, modelCoordinate.longitude);
        m_radar->setObjectsDefaultTexture([[[NSBundle mainBundle] pathForResource:@"yellow"
                                                                           ofType:@"png"
                                                                      inDirectory:@"Assets"] UTF8String]); //CHANGED
        m_radar->setObjectTexture(model, [[[NSBundle mainBundle] pathForResource:@"red"
                                                                          ofType:@"png"
                                                                     inDirectory:@"Assets"] UTF8String]); //CHANGED
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Implement if you need to handle touches
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Implement if you need to handle touches
}

//Added

#pragma mark - Helper methods

- (metaio::IGeometry*)createPOIGeometry:(const metaio::LLACoordinate&)lla
{
    NSString* poiModelPath = [[NSBundle mainBundle] pathForResource:@"ExamplePOI"
                                                             ofType:@"obj"
                                                        inDirectory:@"Assets"]; //CHANGED
    
    assert(poiModelPath);
    
    const char *utf8Path = [poiModelPath fileSystemRepresentation];
    metaio::IGeometry* geo = m_pMetaioSDK->createGeometry(metaio::Path::fromUTF8(utf8Path));
    geo->setTranslationLLA(lla);
    geo->setLLALimitsEnabled(true);
    geo->setScale(100);
    return geo;
}

- (metaio::IGeometry*)loadUpdatedAnnotation:(metaio::IGeometry*)geometry userData:(void*)userData existingAnnotation:(metaio::IGeometry*)existingAnnotation
{
    if (existingAnnotation)
    {
        // We don't update the annotation if e.g. distance has changed
        return existingAnnotation;
    }
    
    if (!userData)
    {
        return 0;
    }
    
    // use this method to create custom annotations
    //UIImage* img = [self getAnnotationImageForTitle:[NSString stringWithUTF8String:(const char*)userData]];
    
    UIImage* thumbnail = [UIImage imageNamed:@"AppIcon72x72~ipad"];
    UIImage* img = metaio::createAnnotationImage(
                                                 [NSString stringWithFormat:@"annotation-%s", (const char*)userData],
                                                 geometry->getTranslationLLA(),
                                                 m_currentLocation,
                                                 thumbnail,
                                                 nil,
                                                 5
                                                 );
    
    return m_pMetaioSDK->createGeometryFromCGImage([[NSString stringWithFormat:@"annotation-%s", (const char*)userData] UTF8String], img.CGImage, true, false);
}



/** This is an example for how you can create custom annotations for your objects */
- (UIImage*)getAnnotationImageForTitle:(NSString*)title
{
    UIImage* bgImage = [UIImage imageNamed:@"../Assets"];
    assert(bgImage);
    
    // Make bgImage.size the real resolution
    bgImage = [UIImage imageWithCGImage:bgImage.CGImage scale:1 orientation:UIImageOrientationUp];
    
    UIGraphicsBeginImageContext(bgImage.size);
    CGContextRef currContext = UIGraphicsGetCurrentContext();
    
    // Mirror the context transformation to draw the images correctly (CG has different coordinates)
    CGContextSaveGState(currContext);
    CGContextScaleCTM(currContext, 1.0, -1.0);
    
    CGContextDrawImage(currContext, CGRectMake(0, 0, bgImage.size.width, -bgImage.size.height), bgImage.CGImage);
    
    CGContextRestoreGState(currContext);
    
    // Add title
    CGContextSetRGBFillColor(currContext, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextSetTextDrawingMode(currContext, kCGTextFill);
    CGContextSetShouldAntialias(currContext, true);
    
    const CGFloat fontSize = floor(bgImage.size.height * 0.5);
    const CGFloat border = floor(bgImage.size.height * 0.1);
    CGRect titleRect = CGRectMake(border, border, bgImage.size.width - 2*border, bgImage.size.height - 2*border);
    const CGSize titleActualSize = [title sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:titleRect.size lineBreakMode:NSLineBreakByTruncatingTail];
    
    // Vertically center text
    titleRect.origin.y += (titleRect.size.height - titleActualSize.height) / 2.0f;
    
    [title drawInRect:titleRect
             withFont:[UIFont systemFontOfSize:fontSize]
        lineBreakMode:NSLineBreakByTruncatingTail
            alignment:NSTextAlignmentCenter];
    
    // Create composed UIImage from the context
    UIImage* finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return finalImage;
}


// ~*~*~*~*


-(void)dismissKeyboard {
    NSLog(@"Keyboard should now dismiss...");
    [searchTextField resignFirstResponder];
}

-(void)updateSearchResults {
    locationResults = [[NSMutableArray alloc] init];
    
    NSLog(@"------");
    NSString *p1 = @"http://api.tripadvisor.com/api/partner/2.0/search/";
    NSString *p2 = @"?key=HackUMass-93b8e93cda61&category=restaurants&limit=6";
    NSString *searchQuery = [NSString stringWithFormat:@"%@/%@/%@", p1, searchTextField.text, p2];
    NSLog(searchQuery);
    
    NSURL *url = [NSURL URLWithString:searchQuery];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if(data != nil) {
        NSDictionary *restaurants = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
        NSLog(@"LEN: %d", [[restaurants objectForKey:@"restaurants"] count]);
    
        for(int i = 0; i < [[restaurants objectForKey:@"restaurants"] count]; i++) {
            NSDictionary *resultsDictionary = [[restaurants objectForKey:@"restaurants"] objectAtIndex:i];
        
            NSString *name = [resultsDictionary objectForKey:@"name"];
            NSString *rating = [resultsDictionary objectForKey:@"rating"];
            NSString *latitude = [resultsDictionary objectForKey:@"latitude"];
            NSString *longitude = [resultsDictionary objectForKey:@"longitude"];
        
            NSLog(name);
        
            Marker *newRes = [Marker createMarker:name rating:rating latitude:latitude longitude:longitude];
        
            // do the insertion
            [locationResults addObject:newRes];
        }
        
        [self.tableView reloadData];
    }
}

-(void)hideSearchResults:(BOOL)hiddenState {
    if(hiddenState == YES && searchTextField.text.length == 0) {
        locationResults = [[NSMutableArray alloc] init];
        [self.tableView reloadData];
    }
    [tableView setHidden:hiddenState];

}

-(void)tapGestureHandler:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:sender.view];
    UIView *viewTouched = [sender.view hitTest:point withEvent:nil];
    
    if ([viewTouched isKindOfClass:[UITableView class]]) {
        // Clicked on table view - hide search results table view
        [searchTextField resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Only need one section
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Don't display section headers
    return nil;
}

// Tap on result cell
- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    // Display beacon!
    NSString *name = [[locationResults objectAtIndex:indexPath.row] nameD];
    NSLog(@"Displaying beacon for: %@", name);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [locationResults count];
}

- (void)handleResultTouch:(id)sender {
    UITapGestureRecognizer *gesture = (UITapGestureRecognizer *) sender;
    NSLog(@"H");
    NSLog(@"Tag = %@", [[locationResults objectAtIndex:gesture.view.tag] nameD]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Create a new Location Object
    Marker *marker = nil;
    marker = [locationResults objectAtIndex:indexPath.row];
    // Configure the cell
    cell.textLabel.text = marker.nameD;
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}



@end



