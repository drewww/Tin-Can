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

@class Todo;

@interface MeetingViewController : UIViewController <AddItemDelegate>{    
    
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
    
    UIPopoverController *addIdeaPopoverController;
    UIPopoverController *addTopicPopoverController;

    AddItemController *addIdeaController;
    AddItemController *addTopicController;
    
    UIButton *addIdeaButton;
    UIButton *addTopicButton;
    
    // Not sure if this should live here or in AppDelegate,
    // but we'll start with here for now.
    NSOperationQueue *queue;
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

- (void) addIdeaButtonPressed:(id) sender;
- (void) addTopicButtonPressed:(id) sender;

@end

