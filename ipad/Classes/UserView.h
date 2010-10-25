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

#define BASE_HEIGHT 70
#define BASE_WIDTH 180

// Messing with this also works for debugging. Set it huge to have max height visibility.
#define HEIGHT_MARGIN 50

#define TAB_WIDTH 15
#define TAB_HEIGHT 15
#define TAB_MARGIN 5

#define STATUS_HEIGHT 30

#define NAME_BOTTOM_MARGIN 5

@class UserRenderView;

@interface UserView : UIView <TaskDropTarget> {
    
    TaskContainerView *taskContainerView;
    UserRenderView *userRenderView;
    
    bool taskDrawerExtended;
    
    float lastHeightChange;
	float initialHeight;
    
    NSNumber *side;
}


- (id) initWithUser:(User *)theUser;

- (void) userTouched;

//- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event;

- (void) taskAssigned:(Task *)theTask;
- (void) taskRemoved:(Task *)theTask;

- (void) setHoverState:(bool)state;
- (void) setDrawerExtended:(bool)extended;

- (NSComparisonResult) compareByLocation:(UserView *)view;

+ (NSArray *) getAllUserViews;

- (User *)getUser;

@property (nonatomic, retain) NSNumber *side;

@end
