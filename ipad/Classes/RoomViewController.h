//
// RoomViewController.h
//  Login
//
//  Created by Drew Harry on 6/18/10.
//  Copyright MIT Media Lab 2010. All rights reserved.
//
#import "LoginMasterViewController.h"
#import <UIKit/UIKit.h>

@class LoginMasterViewController;


@interface RoomViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray *roomList;
	NSMutableArray *meetingList;
	NSMutableArray *countedList;
	LoginMasterViewController *controller;
}

- (id)initWithFrame:(CGRect)frame withController:(LoginMasterViewController *)control;
@property (nonatomic, retain) NSMutableArray *roomList;
@property (nonatomic, retain) NSMutableArray *meetingList;
@property (nonatomic, retain) NSMutableArray *countedList;

@end

