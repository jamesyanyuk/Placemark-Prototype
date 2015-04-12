//
//  ViewController.m
//  Placemark
//
//  Created by James Yanyuk on 4/11/15.
//  Copyright (c) 2015 placemark. All rights reserved.
//

#import "ViewController.h"
#import "Marker.h"

@implementation ViewController

@synthesize locationResults;
@synthesize searchTextField;

@synthesize searchBar;
@synthesize tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"Loaded results table view controller...");
    
    locationResults = [NSArray arrayWithObjects:
                       [Marker createMarker:@"1,1" desc:@"Random 1"],
                       [Marker createMarker:@"1,1" desc:@"Random 2"],
                       [Marker createMarker:@"1,1" desc:@"Random 3"],
                       [Marker createMarker:@"1,1" desc:@"Random 4"], nil];
    
    [self.tableView reloadData];
    
    UIView *subviews = [searchBar.subviews lastObject];
    searchTextField = (id)[subviews.subviews objectAtIndex:1];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(tapGestureHandler:)];
    
    [tableView addGestureRecognizer:tap];
}

-(void)dismissKeyboard {
    NSLog(@"Keyboard should now dismiss...");
    [searchTextField resignFirstResponder];
}

-(void)tapGestureHandler:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:sender.view];
    UIView *viewTouched = [sender.view hitTest:point withEvent:nil];
    
    if ([viewTouched isKindOfClass:[UITableView class]]) {
        [searchTextField resignFirstResponder];
    } else {
        NSLog(@"LEAVE IT :D");
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // The header for the section is the region name -- get this from the region at the section index.
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [locationResults count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Create a new Location Object
    Marker *marker = nil;
    marker = [locationResults objectAtIndex:indexPath.row];
    // Configure the cell
    cell.textLabel.text = marker.desc;
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

@end
