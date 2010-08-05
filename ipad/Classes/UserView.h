//
//  UserView.h
//  TinCan
//
//  Created by Drew Harry on 8/5/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserView : UIView {

    bool hover;
    
    User *user;
    
    // This isn't going to last - color should come from locations, but
    // for now for testing, we're just going to hardcode it.
    UIColor *color;
}

@property (nonatomic, retain) User *user;
@property bool hover;

- (id) initWithUser:(User *)theUser;

- (void) fillRoundedRect:(CGRect)boundingRect withRadius:(CGFloat)radius;

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event;


@end
