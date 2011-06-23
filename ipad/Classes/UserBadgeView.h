//
//  UserBadgeView.h
//  TinCan
//
//  Created by Drew Harry on 6/23/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserBadgeView : UIView {
    UIImageView *icon;
    User *user;
}

- (id) initWithUser:(User *)theUser;

@end
