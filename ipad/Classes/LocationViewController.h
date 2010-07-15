//
//  LocationViewController.h
//  Login
//
//  Created by Drew Harry on 6/18/10.
//  Copyright MIT Media Lab 2010. All rights reserved.
//
#import "LoginMasterViewController.h"
#import <UIKit/UIKit.h>


@class LoginMasterViewController;


@interface LocationViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>{
	
    NSMutableArray *locList;
	LoginMasterViewController *controller;
	
}

- (id)initWithFrame:(CGRect)frame withController:(LoginMasterViewController *)control;
@property (nonatomic, retain) NSMutableArray *locList;

@end

