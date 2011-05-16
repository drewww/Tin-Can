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


@interface LocationViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>{
	
    NSMutableArray *locList;
	LoginMasterViewController *controller;
    
    
    Room *selectedRoom;
}

- (id)initWithFrame:(CGRect)frame withController:(LoginMasterViewController *)control;

- (void) update;

- (void) setSelectedRoom:(Room *)theSelectedRoom;
- (Room *) getSelectedRoom;

@property (nonatomic, retain) NSMutableArray *locList;

@end
