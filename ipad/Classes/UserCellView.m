//
//  LocationCellView.m
//  Login
//
//  Created by Drew Harry on 6/18/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "UserCellView.h"
#import "User.h"

@implementation UserCellView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        self.opaque = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

//Setter for User
- (void) setUser:(User *)newUser {
    user = newUser;
}

- (void) setController:(UserViewController *)theController {
    controller = theController;
}

// Fills the cell with information on Location
- (void)drawRect:(CGRect)rect {
    
    // what the hell? never seen this before. I guess it works(?)
    [[UIColor blackColor] set];
    [user.name drawInRect:CGRectMake(5, 5, 285, 26) withFont:[UIFont systemFontOfSize:18] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    
}

- (void)dealloc {
    [super dealloc];
}


@end
