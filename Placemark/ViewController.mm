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
