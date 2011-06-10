//
//  ManageUsersView.h
//  TinCan
//
//  Created by Drew Harry on 6/9/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ManageUsersTableViewController.h"

@interface ManageUsersView : UIView {

    ManageUsersTableViewController *tableController;
    bool extended;
}

@property (assign) bool extended;

@end
