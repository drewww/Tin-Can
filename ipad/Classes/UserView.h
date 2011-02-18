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

@interface UserView : UIView <TaskDropTarget> {

//    MeetingViewController *controller;
    UIViewController *controller;
    
    TaskContainerView *taskContainerView;
    UserRenderView *userRenderView;
    
    bool taskDrawerExtended;
    bool userExtended;
        
    CGRect initialBounds;
    CGRect initialFrame;
    
    CGRect taskContainerViewInitialFrame;
    
    float drawerExtendAmount;
    
    bool doAutorevert;
    
    NSNumber *side;
}


- (id) initWithUser:(User *)theUser withController:(MeetingViewController *)theController;

- (void) userTouched;

//- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event;

- (void) taskAssigned:(Task *)theTask;
- (void) taskRemoved:(Task *)theTask;

- (void) setHoverState:(bool)state;
- (void) setDrawerExtended:(bool)extended;

- (void) setUserExtended:(bool)extended withAutorevert:(bool)autorevert;
- (void) revertUserExtended;

- (NSComparisonResult) compareByLocation:(UserView *)view;

+ (NSArray *) getAllUserViews;

- (User *)getUser;

- (void) wasLaidOut;

@property (nonatomic, retain) NSNumber *side;
@property (nonatomic, retain) UIViewController *controller;

@end
