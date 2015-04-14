//
//  SearchBarDelegate.m
//  Placemark
//
//  Created by James Yanyuk on 4/11/15.
//  Copyright (c) 2015 placemark. All rights reserved.
//

#import "SearchBarDelegate.h"
#import "ViewController.h"

@implementation SearchBarDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"Search field active");
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    ViewController *rootViewController = window.rootViewController;
    [rootViewController hideSearchResults:NO];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"Search field inactive");
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    ViewController *rootViewController = window.rootViewController;
    [rootViewController hideSearchResults:YES];
}

@end
