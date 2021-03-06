//
//  UserView.h
//  TinCan
//
//  Created by Drew Harry on 8/5/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "TaskContainerView.h"
#import "UserRenderView.h"
#import "TaskDropTarget.h"
#import "ExtendableDrawerView.h"

#define BASE_HEIGHT 90
#define BASE_WIDTH 180

// Messing with this also works for debugging. Set it huge to have max height visibility.
#define HEIGHT_MARGIN 50

#define TAB_WIDTH 5
#define TAB_HEIGHT 12
#define TAB_MARGIN 5

#define LOCATION_HEIGHT 20

#define NAME_BOTTOM_MARGIN 2

#define STATUS_HEIGHT 20

@class UserRenderView;
@class MeetingViewController;


@interface UserView : ExtendableDrawerView <TaskDropTarget> {
    
    UserRenderView *userRenderView;
    UIButton *thumbsUpButton;
    
    bool doAutorevert;    
}


- (id) initWithUser:(User *)theUser;

- (void) userTouched;

- (void) taskAssigned:(Task *)theTask;
- (void) taskRemoved:(Task *)theTask;

- (void) setHoverState:(bool)state;

- (void) setUserExtended:(bool)extended withAutorevert:(bool)autorevert;
- (void) revertUserExtended;

- (void) thumbsUpPressed: (id) sender;
- (void) statusTypeChangedFrom:(StatusType)fromType toType:(StatusType)toType;

- (NSComparisonResult) compareByLocation:(UserView *)view;

+ (NSArray *) getAllUserViews;

- (User *)getUser;

@end
