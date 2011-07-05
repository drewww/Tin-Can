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
#import "Location.h"

@class LoginMasterViewController;


@interface LocationViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>{
	
    NSMutableArray *locList;
	LoginMasterViewController *controller;
    
    
    Room *selectedRoom;
    Location *selectedLocation;
}

- (id)initWithFrame:(CGRect)frame withController:(LoginMasterViewController *)control;

- (void) update;

- (void) setSelectedRoom:(Room *)theSelectedRoom;
- (Room *) getSelectedRoom;

- (void) setSelectedLocation:(Location *)theSelectedLocation;

@property (nonatomic, retain) NSMutableArray *locList;

@end
