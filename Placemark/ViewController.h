//
//  ViewController.h
//  Placemark
//
//  Created by James Yanyuk on 4/11/15.
//  Copyright (c) 2015 placemark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MetaioSDK/MetaioSDKViewController.h>

@interface ViewController : MetaioSDKViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *locationResults;
@property (strong, nonatomic) UITextField *searchTextField;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet GLKView *glView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

-(void)hideSearchResults:(BOOL)hiddenState;

@end

