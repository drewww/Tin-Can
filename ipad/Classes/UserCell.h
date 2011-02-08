//
//  LocationCell.h
// 
//
//  Created by Drew Harry on 6/18/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserCellView.h"
#import "User.h"
#import "UserViewController.h"

@interface UserCell : UITableViewCell {
    UserCellView *userCellView;
    User *user;
}

- (void) setUser:(User *)newUser;
- (void) setController:(UserViewController *)theController;
- (void) setNeedsDisplay;

@end
