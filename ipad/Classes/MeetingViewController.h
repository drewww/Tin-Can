//
//  MeetingViewController.h
//  TinCan
//
//  Created by Drew Harry on 5/10/10.
//  Copyright MIT Media Lab 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingTimerView.h"
#import "TaskContainerView.h"
#import "TopicContainerView.h"
#import "Event.h"
#import "User.h"
#import "LocationBorderView.h"
#import "TimelineContainerView.h"
#import "CurrentTopicView.h"
#import "AddItemController.h"
#import "TrashView.h"
#import "BackdropView.h"
#import "ManageUsersView.h"

@class Todo;

@interface MeetingViewController : UIViewController <AddItemDelegate, BackdropViewDelegate> {    
    
    TaskContainerView *taskContainer;
    TopicContainerView *topicContainer;
    TimelineContainerView *timelineView;
    CurrentTopicView *currentTopicView;
    
    UILabel *connectionInfoLabel;
    
    NSMutableSet *taskViews;

    
    NSMutableDictionary *users;
    NSMutableDictionary *tasks;
    
    MeetingTimerView *meetingTimerView;
    NSTimer *clock;
    
    UIPopoverController *addTaskPopoverController;
    UIPopoverController *addTopicPopoverController;

    AddItemController *addTaskController;
    AddItemController *addTopicController;
    
    UIButton *addTaskButton;
    UIButton *addTopicButton;
    
    LocationBorderView *locBorderView;
    
    // Not sure if this should live here or in AppDelegate,
    // but we'll start with here for now.
    NSOperationQueue *queue;
    
    TrashView *trashView;
    ManageUsersView *manageUsersView;
    
    BackdropView *backdropView;
}


- (void) initUsers;
- (void) initTasks;
- (void) initTopics;

- (void) clk;

- (void) addUserViewForUser:(User *)newUser;
- (void) removeUserViewForUser:(User *)leavingUser;
- (void) layoutUsers;

- (void) handleConnectionEvent:(Event *)event;

- (void) userTaskDrawerExtended:(UserView *)extendedView;

- (void) addTaskButtonPressed:(id) sender;
- (void) addTopicButtonPressed:(id) sender;

- (void) backdropTouchedFrom: (id) sender;
- (void) setBackdropHidden: (bool) hidden;

@end

