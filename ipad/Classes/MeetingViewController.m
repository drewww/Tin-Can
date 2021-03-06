//
//  MeetingViewController.m
//  TinCan
//
//  Created by Drew Harry on 5/10/10.
//  Copyright MIT Media Lab 2010. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MeetingViewController.h"
#import "TaskView.h"
#import "Task.h"
#import "TaskContainerView.h"
#import "UserView.h"
#import "StateManager.h"
#import "TopicContainerView.h"
#import "ConnectionManager.h"
#import "Event.h"
#import "Location.h"
#import "DragManager.h"
#import "LocationBorderView.h"
#import "EventView.h"
#import "CurrentTopicView.h"
#import "AddItemController.h"
#import "TrashView.h"
#import "BackdropView.h"

@class UserView;

@implementation MeetingViewController

#define LONG_DISTANCE_VIEW_TIMEOUT 30
#define THUMBS_UP_TIMEOUT 10.0

#pragma mark Application Events

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {    
    // TODO I don't like having to hardcode the frame here - worried about rotation and 
    // portability / scalability if resolutions change in the future.
    self.view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)] retain];
    [self.view setBackgroundColor:[UIColor blackColor]];
        
    // Now, drop the MeetingTimer in the middle of the screen.
    // Add the timer first, so it's underneath everything.

    Meeting *meeting = [StateManager sharedInstance].meeting;
    NSLog(@" about to init the meeting timer view, meeting: %@; meeting.startedAt: %@", meeting, meeting.startedAt);
    
    // Pull the meeting start time from the actual meeting object that comes from the server.
    meetingTimerView = [[MeetingTimerView alloc] initWithFrame:CGRectMake(200, 200, 200, 200) withStartTime:[StateManager sharedInstance].meeting.startedAt];
    [meetingTimerView retain];
    [self.view addSubview:meetingTimerView];
	
	taskContainer=[[TaskContainerView alloc] initWithFrame:CGRectMake(285, 510, 250, 565) withRot: M_PI/2 isMainView:YES];

	topicContainer=[[TopicContainerView alloc] initWithFrame:CGRectMake(285, -50, 250, 565)];
    
    
    currentTopicView = [[CurrentTopicView alloc] initWithFrame:CGRectMake(490, 462, 290, 100)];
    
    [currentTopicView setTopic:[[StateManager sharedInstance].meeting getCurrentTopic]];
    
    [self.view addSubview:currentTopicView];
    
    
	[self.view addSubview:taskContainer];	
	[self.view addSubview:topicContainer];

    
    // Manage some misc views that we'll want on the edges, too.
    trashView = [[[TrashView alloc] init] retain];
    [self.view addSubview:trashView];
    
    // Make sure to set the location later (it's just local location via StateManager, I suspect)
    manageUsersButtonView = [[ManageUsersContainerView alloc] init];
    manageUsersButtonView.controller = self;
    [self.view addSubview:manageUsersButtonView];
    
    // If we don't call this here, the trash won't get laid out properly unless there's another user in the room.
    [self layoutUsers];
    
    [[DragManager sharedInstance] setRootView:self.view andTaskContainer:taskContainer andTrashView:trashView];

	[self.view bringSubviewToFront:meetingTimerView];
	[self.view bringSubviewToFront:topicContainer];
    [self.view bringSubviewToFront:currentTopicView];
    [self.view bringSubviewToFront:taskContainer];

    // Now setup the backdrop view. It'll sit ABOVE the major containers but BELOW the buttons and 
    // users, so you can still click on those directly. We'll make it, put it in place, then hide it
    // so it doesn't get touches until a drawer is extended.
    backdropView = [[BackdropView alloc] initWithFrame:self.view.frame];
    backdropView.delegate = self;
    
    [self.view addSubview: backdropView];
    [self.view bringSubviewToFront:backdropView];
    
    queue = [[[NSOperationQueue alloc] init] retain];
    
    locBorderView = [[LocationBorderView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:locBorderView];
    [self.view sendSubviewToBack:locBorderView];
    
    timelineView=[[TimelineContainerView alloc] initWithFrame:CGRectMake(44, 409, 290, 208)];
    [self.view addSubview:timelineView];

    
    // Add a pair of buttons for adding topics and adding tasks. This is instead of the + buttons on the 
    // container views for those types, which are absurdly hard to hit on an actual ipad.
    addTaskButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    addTaskButton.frame = CGRectMake(-15, 775, 240, 30);
    addTaskButton.backgroundColor = [UIColor clearColor];
    [addTaskButton setTitle:@"Add Task" forState: UIControlStateNormal];
    addTaskButton.titleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
    [addTaskButton addTarget:self action:@selector(addTaskButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
    [addTaskButton setEnabled: YES];
    
    addTaskButton.backgroundColor = [UIColor blackColor];
    addTaskButton.transform = CGAffineTransformMakeRotation(M_PI/2);
    
    [self.view addSubview:addTaskButton];

    
    addTopicButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    addTopicButton.frame = CGRectMake(-15, 220, 240, 30);
    addTopicButton.backgroundColor = [UIColor clearColor];
    [addTopicButton setTitle:@"Add Topic" forState: UIControlStateNormal];
    addTopicButton.titleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
    [addTopicButton addTarget:self action:@selector(addTopicButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
    [addTopicButton setEnabled: YES];
    
    addTopicButton.backgroundColor = [UIColor blackColor];
    addTopicButton.transform = CGAffineTransformMakeRotation(M_PI/2);
    
    [self.view addSubview:addTopicButton];
    
    
    // Set up the two popover controllers.
    addTaskController = [[AddItemController alloc] initWithPlaceholder:@"new task" withButtonText:@"Add Task" withAltButtonText:nil];
    addTaskController.delegate = self;
    
    addTaskPopoverController = [[UIPopoverController alloc] initWithContentViewController:addTaskController];
    [addTaskPopoverController setPopoverContentSize:CGSizeMake(300, 100)];

    addTopicController = [[AddItemController alloc] initWithPlaceholder:@"new topic" withButtonText:@"Add Topic" withAltButtonText:nil];
    addTopicController.delegate = self;
    
    addTopicPopoverController = [[UIPopoverController alloc] initWithContentViewController:addTopicController];
    [addTopicPopoverController setPopoverContentSize:CGSizeMake(300, 100)];
    
    [self initUsers];
    [self initTasks];
    [self initTopics];
    
    [self.view bringSubviewToFront:manageUsersButtonView];
    
    NSLog(@"Done loading view.");
    
    
    // Now register as an event listener on the ConnectionManager, so we can update
    // the view in response to changes.
    [[ConnectionManager sharedInstance] addListener:self];
    
    
    // Set up a label for displaying information about connection issues.
    connectionInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-350/2, self.view.frame.size.height/2.0-200/2, 350, 200)];
    [connectionInfoLabel setTransform:CGAffineTransformMakeRotation(M_PI/2)];
    connectionInfoLabel.numberOfLines = 3;
    connectionInfoLabel.textAlignment = UITextAlignmentCenter;
    connectionInfoLabel.textColor = [UIColor whiteColor];
    connectionInfoLabel.backgroundColor = [UIColor colorWithRed:0.5 green:0.3 blue:0.3 alpha:1.0];
    connectionInfoLabel.font = [UIFont boldSystemFontOfSize:30.0f];
    connectionInfoLabel.layer.cornerRadius = 8;    
    connectionInfoLabel.alpha = 0.9;
    
    
    manageUsersView = [[[ManageUsersView alloc] init] retain];
    
    // Could maybe do something fancy with grabbing this on first storage in the manageUsersView
    // class, but I'm so tired of this whole sequence that I don't want to add any complexity.
    initialManageUsersCenter = CGPointMake(384+768, 512);
    manageUsersView.center = initialManageUsersCenter;
    manageUsersView.transform = CGAffineTransformMakeRotation(M_PI/2);
    [self.view addSubview:manageUsersView];
    [self.view bringSubviewToFront:manageUsersView];
    
    // Create the long distance view.
    // In the final version, this will start hidden and appear later. But for now, we're going
    // to create it and have it shown immediately.
    longDistanceView = [[[LongDistanceView alloc] init] retain];
    longDistanceView.frame = CGRectMake(45, 45, longDistanceView.frame.size.width, longDistanceView.frame.size.height);
    [self.view addSubview:longDistanceView];
    [self.view bringSubviewToFront:longDistanceView];
    longDistanceView.hidden = true;

    lastTouch = [[NSDate date] retain];

    
    // Turn on notifications of device orientation changes so we can dismiss the screen when someone picks it up.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    animating = false;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];    
    
    // Kick off the timer.
    clock = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(clk) userInfo:nil repeats:YES];
    [clock retain];    
    
    // Push an update into the queue.
    
    NSLog(@"viewDidLoad");
}


- (void) handleConnectionEvent:(Event *)event {
    NSLog(@"got connection event type: %d", event.type);
    
    StateManager *state = [StateManager sharedInstance];
    
    // First, check and see if this is an event for our meeting. If it's not,
    // then drop it.
    Meeting *curMeeting = [StateManager sharedInstance].meeting;
    
    if(event.meetingUUID != nil && ![event.meetingUUID isKindOfClass:[NSNull class]]) {
        NSLog(@"event.meeting: %@, currentMeetingUUID: %@", event.meetingUUID, curMeeting.uuid);
        if(![event.meetingUUID isEqualToString:curMeeting.uuid]) {
            NSLog(@"Received meeting-level event for another meeting. Discarding it.");
            return;
        }
    }
    
    
    NSLog(@"passed meeting UUID check");
    
    // Otherwise, we're getting all the global events and and local events for
    // our meeting. We're still going to have to discard some of these (eg users joining
    // locations other than the ones in this meeting) but those checks need to be
    // special and per-event-type, not global.

    Location *location;
    Task *task;
    switch(event.type) {
        case kADD_ACTOR_DEVICE:
            // Don't need to do anything here.
            break;
            
        case kNEW_USER:
            break;
            
        case kNEW_MEETING:
            break;
            
        case kUSER_LEFT_LOCATION:
            // if it's a location in our meeting, then
            // remove those users from the display.
            location = (Location *)[state getObjWithUUID:[event.params objectForKey:@"location"]
                                                withType:[Location class]];
            
            NSLog(@"User left a location, and the meeting view control got notice of it.");
            if([curMeeting.locations containsObject:location]) {
                User *user = (User *)[state getObjWithUUID:event.actorUUID withType:[User class]];
                [self removeUserViewForUser:user];
            }
            
            [[location getView] setNeedsDisplay];
            [locBorderView setNeedsDisplay];
            
        break;
           
            
        case kUSER_JOINED_LOCATION:
            // add views for those users. 
            location = (Location *)[state getObjWithUUID:[event.params objectForKey:@"location"]
                                                    withType:[Location class]];
            
            NSLog(@"location being joined: %@", location);
            NSLog(@"locations in this meeting: %@", curMeeting.locations);
            
            if([curMeeting.locations containsObject:location]) {
                NSLog(@"User joined a location in this meeting!");
                User *user = (User *)[state getObjWithUUID:event.actorUUID withType:[User class]];
                [self addUserViewForUser:user];
            }
            
            // Also, ask the user's location to redraw itself.
            [[location getView] setNeedsDisplay];
            [locBorderView setNeedsDisplay];
                    
            break;
            
        case kLOCATION_LEFT_MEETING:
            // If it's a location 
            location = (Location *)[state getObjWithUUID:event.actorUUID withType:[Location class]];

            // We used to test to make sure that the meeting had this location
            // before removing the users. I'm not sure why that test was here, but
            // it's causing trouble now because this executes after the ConnectionManager
            // event processes and it removes the location from the meeting, making this
            // test always fail (even when it should pass). So for now just dropping
            // the test entirely.
            //            if([curMeeting.locations containsObject:location]) {
            
            NSLog(@"Location in this meeting left it!");
            
            for(User *user in location.users) {
                [self removeUserViewForUser:user];
            }
            
            // Remove the location object from the display, too.
            // (this might be obselete - do we even have location views anymore?)
            [[location getView] removeFromSuperview];
            
            break;
            
        case kLOCATION_JOINED_MEETING:
            location = (Location *)[state getObjWithUUID:event.actorUUID withType:[Location class]];
            
            if([curMeeting.locations containsObject:location]) {
                NSLog(@"another location joined this meeting! with users: %@", location.users);
                for(User *user in location.users) {
                    [self addUserViewForUser:user];
                }
            }
            
            // Add the new location to the location container.
            // Deprecated for now, because we're not using 
            // a dedicated location container view for now.
            // This might get turned back on later if we add
            // a modal one.
            
            // [locContainer addSubview:[location getView]];
            
            break;
            
        case kNEW_TOPIC:
            NSLog(@"adding new topic");
            // Add the topic to the topic list.
            [topicContainer addTopicView:[[event.results objectForKey:@"topic"] getView]];
            [longDistanceView setNeedsDisplay];
            break;
            
        case kUPDATE_TOPIC:
            [topicContainer setNeedsLayout];
            
            [currentTopicView setTopic:[state.meeting getCurrentTopic]];
            [longDistanceView setNeedsDisplay];            
            break;
            
        case kNEW_TASK:
            NSLog(@"adding new task to the task container.");
            
            task = [event.results objectForKey:@"task"];
            
            if([task isAssigned]) {
                NSLog(@"Found a new task that is already assigned on creation.");
                
                // This is obviously a bit wonky - all the data is already there. But this routes
                // through the task assiginment code that's already there and handles the view stuff
                // in a consistent way.
                [task assignToUser:task.assignedTo byActor:task.assignedTo atTime:[NSDate date]];
            } else {
                [taskContainer addTaskView:(TaskView *)[[event.results objectForKey:@"task"] getView]];
            }
            
            // Is there a different way to do this? In this c
            [longDistanceView setNeedsDisplay];
            break;
            
        case kDELETE_TASK:
            break;
            
        case kEDIT_TASK:
            break;
            
        case kASSIGN_TASK:
            NSLog(@"assigning tasks in the meeting view controller because I'm a bad person");
            
            task = (Task *)[state getObjWithUUID:[event.params objectForKey:@"taskUUID"] withType:[Task class]];
            
            NSLog(@"in assign task handler");
            
            Actor *assignedBy = (Actor *)[state getObjWithUUID:event.actorUUID withType:[Actor class]];
            NSDate *assignedAt = [NSDate dateWithTimeIntervalSince1970:[[event.params objectForKey:@"assignedAt"] doubleValue]];
            
            if([((NSNumber *)[event.params objectForKey:@"deassign"]) intValue] == 1) {
                // Do deassign logic.   
                [task startDeassignByActor:assignedBy atTime:assignedAt withTaskContainer:taskContainer];
            } else {
                // Do assign logic.
                User *assignedTo = (User *)[state getObjWithUUID:[event.params objectForKey:@"assignedTo"] withType:[User class]];
                
                [task startAssignToUser:assignedTo byActor:assignedBy atTime:assignedAt];
            }
            [longDistanceView setNeedsDisplay];
            break;
            
        case kEDIT_MEETING:
            break;
            
        case kNEW_DEVICE:
            break;
            
        case kCONNECTION_STATE_CHANGED:
            if([[ConnectionManager sharedInstance].serverReachability currentReachabilityStatus]==NotReachable) {
                connectionInfoLabel.text = [NSString stringWithFormat:@"Lost wireless connectivity."];                    
                [self.view addSubview:connectionInfoLabel];
            }            
            break;
        case kUPDATE_STATUS:
            // All we need to do here is force a redraw on the user with the updated status.
            NSLog(@"Forcing redraw in users whose status have been updated.");
            
            Actor *actor = (Actor *)[state getObjWithUUID:event.actorUUID withType:[Actor class]];
            
            if([actor isKindOfClass:[User class]]) {
                User *user = (User *)actor;
                [[user getView] setNeedsDisplay];
                UserView *userView = (UserView *)[user getView];
                [userView setUserExtended:true withAutorevert:true];
            }
            
            break;
        case kTHUMBS_UP:
            NSLog(@"bullshit case statement issue.");
            
            User *user = (User *)[state getObjWithUUID:event.actorUUID withType:[User class]];
            
            // force a nice animation to trigger here.
            
            // Update the global "last thumbs up" time and kick off a deferred check.
            [lastThumbsUp release];
            lastThumbsUp = [[NSDate date] retain];
            
            [self performSelector:@selector(thumbsUpCallback) withObject:self afterDelay:THUMBS_UP_TIMEOUT];
            
            // trigger a redraw.
            [[user getView] setNeedsDisplay];
            break;
            
        case kCONNECTION_REQUEST_FAILED:
            
            connectionInfoLabel.text = @"Lost connection to the server.";
            [self.view addSubview:connectionInfoLabel];
            
            break;
            
        default:
            NSLog(@"Received an unknown event type: %d", event.type);
            break;
            
    }
    
    NSLog(@"done with event dispatch, gonna add it to the timeline now");
    
    // Okay, now for every event, we want to add an entry to the timeline view.
    // This frame is arbitrary - the layout system will take it over when added.
    switch(event.type) {
        case kNEW_TASK:
            task = [event.results objectForKey:@"task"];
            
            // If the task is assigned, don't add an entry to the timeline container.
            // This avoids cluttering it up with doubles when people create in
            // the public timeline.
            if(![task isAssigned]) {
                break;
            }

        case kUSER_JOINED_LOCATION:
        case kUSER_LEFT_LOCATION:
        case kUPDATE_TOPIC:
        case kASSIGN_TASK:
        case kNEW_TOPIC:
//        case kLOCATION_LEFT_MEETING:
//        case kLOCATION_JOINED_MEETING:
            NSLog(@"... stupid bug.");
            
            EventView *eventView = [[EventView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) withEvent:event];
            [timelineView addEventView:eventView];
            [timelineView setNeedsLayout];
            [timelineView setNeedsDisplay];
            
            break;
    }
    
    [longDistanceView handleConnectionEvent:event];
    
}

- (void) thumbsUpCallback {
    // Check and see if it's been the window distance (it will for sure have been at least that long, but
    // another thumbs up may have arrived in that window)
    
    NSLog(@"Got thumbsUp callback! interval: %f > %d = %d", fabs([lastThumbsUp timeIntervalSinceNow]),THUMBS_UP_TIMEOUT, abs([lastThumbsUp timeIntervalSinceNow]) > THUMBS_UP_TIMEOUT);
    if(fabs([lastThumbsUp timeIntervalSinceNow]) > THUMBS_UP_TIMEOUT) {
        NSLog(@"removing thumbs up markers");
        // Set everyone who has a thumbs up to EMPTY.
        for (User *user in [StateManager sharedInstance].meeting.currentParticipants) {
            if(user.statusType==kTHUMBS_UP_STATUS) {
                user.statusType=kEMPTY_STATUS;
                [[user getView] setNeedsDisplay];
            }
        }
    }
    
}

- (void) addTaskButtonPressed:(id) sender {
    NSLog(@"In ADD TASK BUTTON PRESSED.");
    [self userTaskDrawerExtended:nil];
    [addTaskPopoverController presentPopoverFromRect:addTaskButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
}

- (void) addTopicButtonPressed:(id) sender {
    NSLog(@"In ADD TOPIC BUTTON PRESSED.");
    [self userTaskDrawerExtended:nil];
    [addTopicPopoverController presentPopoverFromRect:addTopicButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];    
}


- (void) itemSubmittedWithText:(NSString *)text fromController:(UIViewController *)controller isAltSubmit:(bool)isAltSubmit{

    NSLog(@"item submitted! text: %@ fromController: %@", text, controller);
    
    if(controller == (UIViewController *)addTaskController) {
        [addTaskPopoverController dismissPopoverAnimated:true];

        [[ConnectionManager sharedInstance] addTaskWithText:text isInPool:true isCreatedBy:nil isAssignedBy:nil];
        
        if(isAltSubmit) {
            [[ConnectionManager sharedInstance] addTaskWithText:text isInPool:true isCreatedBy:nil isAssignedBy:nil];            
        }
        
    } else if (controller == (UIViewController *)addTopicController) {
        [addTopicPopoverController dismissPopoverAnimated:true];
        [[ConnectionManager sharedInstance] addTopicWithText:text];        
    }
}


- (void) toggleManageUsers {
    [self setManageUsersView:!manageUsersView.extended];
}

- (void) setManageUsersView:(bool) extended {
    
    
    CGPoint newCenter;
    if(extended) {
        // This will hide other drawers.
        [self userTaskDrawerExtended:manageUsersButtonView];
        newCenter = CGPointMake(384, 512);
        manageUsersView.extended = true;
    } else {
        newCenter = initialManageUsersCenter;
        manageUsersView.extended = false;
    }
    
    
    // now to actually extend the drawer.
    [UIView beginAnimations:@"extend_manage_users" context:nil];
    
    manageUsersView.center = newCenter;
    
    [UIView commitAnimations];
    
    
}

- (void) userTaskDrawerExtended:(UIView *)extendedView {
    
    // Loop through all our subviews and look for ones that are UserViews. 
    // Send a message to all of them (except the one that actually extended)
    // to retract their own trask drawer.
    
    // Going to need to add in the manage users view to this list 
    
    
    for (UserView *view in [UserView getAllUserViews]) {
            if(view != extendedView) {
                [view setDrawerExtended:false];
        }
    }
    
    if(extendedView != manageUsersButtonView) {
        NSLog(@"Setting MANAGE USERS VIEW to be retracted.");
        [self setManageUsersView:FALSE];
    }
    
    if(extendedView != nil) {
        [self setBackdropHidden:FALSE];
        [self processTouch];
    }
}

- (void) addUserViewForUser:(User *)newUser {
    
    [self.view addSubview:[newUser getView]];
    [self.view bringSubviewToFront:[newUser getView]];
    ((UserView *)[newUser getView]).controller = self;
    
    [self layoutUsers];
}

- (void) removeUserViewForUser:(User *)leavingUser {
    [[leavingUser getView] removeFromSuperview];
    [self layoutUsers];
}

- (void) layoutUsers {
    // First, sort the users so they get grouped properly by location.
    NSArray *sortedUserViews = [UserView getAllUserViews];
    
    NSMutableArray *finalSortedViews = [NSMutableArray arrayWithArray:sortedUserViews];
    
    [finalSortedViews addObject:trashView];
    [finalSortedViews addObject:manageUsersButtonView];
    sortedUserViews = finalSortedViews;
        
    int numViews = [sortedUserViews count];
    
    int i = 0;
    int arrayCounter=0;
    int sideLimit= ceil(numViews/4.0);
    int topLimit=trunc(numViews/4.0);
    
    //assigns number of participants to a side
    NSMutableArray *sides=[[NSMutableArray arrayWithObjects:[NSNumber numberWithInt: 0],[NSNumber numberWithInt:0],
                            [NSNumber numberWithInt:0],[NSNumber numberWithInt:0],nil]retain];
    
    while (i<numViews) {
        if (arrayCounter==1 && ([[sides objectAtIndex:arrayCounter] intValue]>=topLimit)) {
            arrayCounter++;
        }
        else if ((arrayCounter==0 || arrayCounter==2)&&([[sides objectAtIndex:arrayCounter] intValue] >=sideLimit)){
            arrayCounter++;
        }
        else if(arrayCounter==3){
            if ([[sides objectAtIndex:arrayCounter] intValue]>topLimit) {
                break;
            }
            else {
                [sides replaceObjectAtIndex: arrayCounter withObject:[NSNumber numberWithInt:[[sides objectAtIndex:arrayCounter] intValue] +1.0]];
                arrayCounter=0;	
                i++;
            }
        }
        else {
            [sides replaceObjectAtIndex: arrayCounter withObject:[NSNumber numberWithInt:[[sides objectAtIndex:arrayCounter] intValue] +1.0]];
            i++;
            arrayCounter++;
        }	
        
    }
    
    // Iterates through each of the side buckets and places the views along
    // that side with appropriate spacing.
    //
    // On the first and last sides, we flip the direction (1024- or 768-) to ensure
    // that the points come out in clockwise order starting from the bottom left
    // on the screen in landscape mode. This ensures that if we order users in a
    // particular way in the array of views, they'll be placed on the screen in 
    // that order as well. 
    NSMutableArray *points=[[NSMutableArray alloc] initWithCapacity:numViews];
    NSMutableArray *rotations=[[NSMutableArray alloc] initWithCapacity:numViews];
    NSMutableArray *sidesList=[[NSMutableArray alloc] initWithCapacity:numViews];
    for (i=0; i<4; i++) {
        
        // Set the side variable to help the border layout system later.
        // This is a bit of a hassle because the mappings are different, but
        // this method does bottom, left, top, right, while the normal
        // numbering is top, right, bottom, left. Do the conversion here.
        // (would like to be pulling this numbering from the UserView class
        // but not sure how to make those constants available here. Extern 
        // something?)
        int side;
        switch (i) {
            case 0:
                side=2;
                break;
            case 1:
                side=3;
                break;
            case 2:
                side=0;
                break;
            case 3:
                side=1;
                break;
        }
        
        int c =1;
        while (c<=[[sides objectAtIndex:i] intValue]) {
            if (i==0|| i==2) {
                float divisions=1024.0/[[sides objectAtIndex:i] intValue];
                float yVal= (divisions*c) -(divisions/2.0);
                if (i==0) {
                    [points addObject:[NSValue valueWithCGPoint:CGPointMake(0, 1024-yVal)]];
                    [rotations addObject:[NSNumber numberWithFloat:M_PI/2]];
                    
                }	
                else{
                    [points addObject:[NSValue valueWithCGPoint:CGPointMake(768, yVal)]];
                    [rotations addObject:[NSNumber numberWithFloat:-M_PI/2]]; 
                }
            }
            else if (i==1 || i==3) {
                float divisions=768/[[sides objectAtIndex:i] intValue];
                float xVal= (divisions*(c)) -(divisions/2.0);
                if (i==1) {
                    [points addObject:[NSValue valueWithCGPoint:CGPointMake(xVal, 0)]]; 
                    [rotations addObject:[NSNumber numberWithFloat:M_PI]];
                }	
                else{
                    [points addObject:[NSValue valueWithCGPoint:CGPointMake(768-xVal, 1024)]];
                    [rotations addObject:[NSNumber numberWithFloat:0.0]];
                }
            }
            
            [sidesList addObject:[NSNumber numberWithInt:side]];
            c++;
        }
    }
    // Now that we've done all the layout math, put everything in its place.
    int viewIndex = 0;
    
    for(UserView *view in sortedUserViews) {
        view.center = [[points objectAtIndex:viewIndex] CGPointValue];
              
        [view setTransform:CGAffineTransformMakeRotation([[rotations objectAtIndex:viewIndex] floatValue])];
        
        // The trash object is in here, too.
        if([view isKindOfClass:[ExtendableDrawerView class]]) {
            view.side = [sidesList objectAtIndex:viewIndex];
            [view wasLaidOut];
        }
        
        if([view isKindOfClass:[ManageUsersContainerView class]]) {
            view.side = [sidesList objectAtIndex:viewIndex];
            [view setNeedsDisplay];
        }
        
        viewIndex++;
    }   
    
    [locBorderView setNeedsDisplay];
}

- (void) setBackdropHidden: (bool) hidden {
    NSLog(@"Setting backdrop hidden: %d", hidden);
    backdropView.hidden = hidden;
}

- (void) backdropTouchedFrom:(id)sender {
    // Hide all drawers.
    [self userTaskDrawerExtended:nil];
    
    // Hide the backdrop itself.
    backdropView.hidden = TRUE;
    
    [self processTouch];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    
    [meetingTimerView release];
    meetingTimerView = nil;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"got a touch in the view controller");
    [self processTouch];
}

- (void) processTouch {
    NSLog(@"---------------------- PROCESS TOUCH --------------------------");
    [lastTouch release];
    lastTouch = [[NSDate date] retain];
    
    [self setLongDistanceViewVisible:false];    
}

- (void) setLongDistanceViewVisible:(bool) visible {    
    // This helps filter out rapid requests to hide/show, which seem to
    // interrupt the animation and force it to complete rapidly.
    if(animating) {
        return;
    }
    
    if(longDistanceView.hidden && visible) {
        longDistanceView.hidden = false;
        [UIView animateWithDuration:0.5
                         animations:^{ 
                             animating = true;
                             longDistanceView.alpha = 1.0;
                         } 
                         completion:^(BOOL finished){
                             animating = false;
                         }];
        
    } else if (!longDistanceView.hidden && !visible) {
        // transition to invisibility
        [UIView animateWithDuration:0.5
                         animations:^{ 
                             animating = true;
                             longDistanceView.alpha = 0.0;
                         } 
                         completion:^(BOOL finished){
                             animating = false;
                             longDistanceView.hidden = true;
                         }];
    }
    
    // Hide all user drawers.
    if(visible) {
        [self userTaskDrawerExtended:nil];
    }
}

- (void) orientationChanged:(NSNotification *)notification {
    [lastTouch release];
    lastTouch = [[NSDate date] retain];
    
    [self setLongDistanceViewVisible:false];        
}


- (void)dealloc {
    [super dealloc];
    [self.view release];
    
    [users release];
    [tasks release];
    
    [taskViews release];
    
    [queue release];
    
    [longDistanceView release];
    [manageUsersView release];
    
    [clock invalidate];
}




#pragma mark Internal Methods

- (void)clk {
    [meetingTimerView clk];
    [topicContainer setNeedsDisplay];
    [currentTopicView setNeedsDisplay];
    [longDistanceView clk];
    
    
    // Check to see if it's been more than the LONG_DISTANCE_VIEW_TIMEOUT
    // If it has, bring in the long distance view.
    if(abs([lastTouch timeIntervalSinceNow]) > LONG_DISTANCE_VIEW_TIMEOUT && longDistanceView.hidden) {
        [self setLongDistanceViewVisible:true];
    }
}   


- (void) initUsers {
    // Ask the state manager for all the users, and make views for them.
    
    int i=0;
    for(User *user in [StateManager sharedInstance].meeting.currentParticipants) {
        NSLog(@"Creating UserView for user: %@", user);
        
        // The user knows how to construct its own view if it doesn't have one yet. 
        // This will avoid double-creating if for some reason someone else needs the User's view.
//        UserView *view = (UserView *)[user getView];//changed UIView to UserView to get rid of yellow error
        
        [self addUserViewForUser:user];
        
        
//        [view setNeedsDisplay];
        
        i++;
    }

}

- (void) initTasks {
    
    
    NSSet *unassignedTasks = [[[StateManager sharedInstance].meeting getUnassignedTasks] retain];    
    // Look at the meeting objecet and see if there are any unassigned tasks. 
    for(Task *task in unassignedTasks) {
        [taskContainer addTaskView:(TaskView *)[task getView]];
    }
    
    [taskContainer setNeedsLayout];
    [taskContainer setNeedsDisplay];
    
    [unassignedTasks release];
}

- (void) initTopics {
    NSLog(@"in initTopics");
    NSSet *topics = [[[StateManager sharedInstance].meeting.topics copy] retain];
    NSLog(@"got some topics.");
    NSLog(@"%d topics", [topics count]);
    
    for (Topic *topic in topics) {
        [topicContainer addTopicView:[topic getView]];
    }
    
    [topicContainer setNeedsLayout];
    
    [topics release];
}


#pragma mark Communication Handling


@end
