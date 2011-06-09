//
//  ManageUsersTableViewController.h
//  TinCan
//
//  Created by Drew Harry on 6/8/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface ManageUsersTableViewController : UITableViewController {
    NSArray *userList;
}

- (void) extended;
- (void) updateUsers;

@end
