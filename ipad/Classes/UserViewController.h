//
//  LocationViewController.h
//  Login
//
//  Created by Drew Harry on 6/18/10.
//  Copyright MIT Media Lab 2010. All rights reserved.
//
#import "LoginMasterViewController.h"
#import <UIKit/UIKit.h>
#import "ConnectionManager.h"
#import "StateManager.h"
#import "Room.h"

@class LoginMasterViewController;


@interface UserViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>{

	NSMutableArray *userList;
	LoginMasterViewController *controller;

    User *selectedUser;
}

- (id)initWithFrame:(CGRect)frame withController:(LoginMasterViewController *)control;

- (void) update;

- (void) setSelectedUser:(User *)theSelectedUser;
- (User *) getSelectedUser;

@property (nonatomic, retain) NSMutableArray *userList;

@end

