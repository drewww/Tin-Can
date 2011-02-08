//
//  UserCell.m
//  Login
//
//  Created by Drew Harry on 6/18/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "UserCell.h"
#import "UserCellView.h"
#import "User.h"
#import "UserViewController.h"

@implementation UserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
       
        CGRect tzvFrame = CGRectMake(0.0, 0.0, 320, self.contentView.bounds.size.height);

        userCellView = [[UserCellView alloc] initWithFrame:tzvFrame];
        userCellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.contentView addSubview:userCellView];
    }
    return self;
}


//Setter for Location
- (void) setUser:(User *)newUser {
    
    [userCellView setUser:newUser];
}

- (void) setController:(UserViewController *)theController {
    [userCellView setController:theController];
}

- (void) setNeedsDisplay {
    [userCellView setNeedsDisplay];   
}

- (void)dealloc {
    [super dealloc];
}


@end
