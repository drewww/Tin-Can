//
//  MeetingViewController.h
//  TinCan
//
//  Created by Drew Harry on 5/10/10.
//  Copyright MIT Media Lab 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MeetingTimerView.h"
#import "ParticipantView.h"
#import "Todo.h"
#import "TaskContainerView.h"
#import "TopicContainerView.h"
#import "LocationContainerView.h"
#import "Event.h"

@class Todo;

@interface MeetingViewController : UIViewController {    
    UIView *participantsContainer;
    
    TaskContainerView *taskContainer;
    TopicContainerView *topicContainer;
	LocationContainerView *locContainer;
    
    NSMutableSet *todoViews;

    
    NSMutableDictionary *participants;
    NSMutableDictionary *todos;
    
    MeetingTimerView *meetingTimerView;
    NSTimer *clock;
        
    // Not sure if this should live here or in AppDelegate,
    // but we'll start with here for now.
    NSOperationQueue *queue;
    
    int lastRevision;
}


// These are deprecated, but I'm leaving them behind so we can still test thsoe views
// if the server-based objects turn into a problem.
- (void) initParticipantsView;
- (void) initTodoViews;

- (void) initUsers;
- (void) initTasks;

- (void) clk;

- (void) addTodo:(Todo *)todo;

- (void) dispatchTodoCommandString:(NSString *)operation fromRevision:(int)revision;

- (void) handleNewTodoWithArguments:(NSArray *)args;
- (void) handleAssignTodoWithArguments:(NSArray *)args;

- (void) handleConnectionEvent:(Event *)event;


- (CGPoint) getNextTodoPosition;

@end

