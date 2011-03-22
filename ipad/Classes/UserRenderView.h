//
//  UserRenderView.h
//  TinCan
//
//  Created by Drew Harry on 8/5/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

// This class shouldn't exist, but it's a way of coding around some view problems
// we're having. The way views that contain other views work is:
//
// 1) The parent view executes its drawRect method.
// 2) It iterates through its subviews, asking them to do their drawRects.
//
// This means that there is no way for a parent's drawRect drawing to happen ON TOP
// of ANY contained subview. Although there are structural reasons for apple to do it
// this way, it's pretty aggravating here. We want the user's task drawer to be 
// underneath the actual user drawing, so it can slide nicely out from underneath.
// The only way to make this happen is to remove the user drawing code from the parent
// class and put it in its own subview, and then order the subviews appropriately
// for this effect. This is a ton of unnecessary added complexity, but I'm confident
// that there's no way around it. QQ
//
// This is a decent discussion of this issue:
// http://forums.pragprog.com/forums/83/topics/3124

@interface UserRenderView : UIView {

    bool hover;
    bool showStatus;
    bool taskDrawerExtended;
    
    User *user;    
}

- (id) initWithUser:(User *)theUser;


@property (nonatomic, retain) User *user;
@property bool hover;


@end
