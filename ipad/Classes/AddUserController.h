//
//  AddUserController.h
//  TinCan
//
//  Created by Drew Harry on 12/8/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@protocol AddUserDelegate
- (void) userSelected:(User *)userToAdd;
@end


@interface AddUserController : UITableViewController {
    id <AddUserDelegate> _delegate;
    
    NSArray *allUsers;
}


@property (nonatomic, assign) id <AddUserDelegate> delegate;

@end
