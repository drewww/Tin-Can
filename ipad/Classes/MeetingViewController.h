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
#import "LocationContainerView.h"
#import "Event.h"

@class Todo;

@interface MeetingViewController : UIViewController {    
    UIView *userContainer;
    
    TaskContainerView *taskContainer;
    TopicContainerView *topicContainer;
	LocationContainerView *locContainer;
    
    NSMutableSet *taskViews;

    
    NSMutableDictionary *users;
    NSMutableDictionary *tasks;
    
    MeetingTimerView *meetingTimerView;
    NSTimer *clock;
        
    // Not sure if this should live here or in AppDelegate,
    // but we'll start with here for now.
    NSOperationQueue *queue;
    
    int lastRevision;
}


- (void) initUsers;
- (void) initTasks;
- (void) initTopics;

- (void) clk;

- (void) handleConnectionEvent:(Event *)event;

@end

