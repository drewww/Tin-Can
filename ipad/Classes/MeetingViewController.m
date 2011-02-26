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

@class UserView;

@implementation MeetingViewController

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
	
	taskContainer=[[TaskContainerView alloc] initWithFrame:CGRectMake(260, -65, 250, 600) withRot: M_PI/2 isMainView:YES];

	topicContainer=[[TopicContainerView alloc] initWithFrame:CGRectMake(260, 490, 250, 600)];
    
    
    currentTopicView = [[CurrentTopicView alloc] initWithFrame:CGRectMake(490, 462, 290, 100)];
    
    [currentTopicView setTopic:[[StateManager sharedInstance].meeting getCurrentTopic]];
    
    [self.view addSubview:currentTopicView];
    
    
	[self.view addSubview:taskContainer];	
	[self.view addSubview:topicContainer];

    [[DragManager sharedInstance] setRootView:self.view andTaskContainer:taskContainer];

	[self.view bringSubviewToFront:meetingTimerView];
	[self.view bringSubviewToFront:topicContainer];
    [self.view bringSubviewToFront:taskContainer];

    queue = [[[NSOperationQueue alloc] init] retain];
    
    //timelineView=[[TimelineContainerView alloc] initWithFrame:CGRectMake(44, 409, 290, 208)];
    //[self.view addSubview:timelineView];

    
    // Add a pair of buttons for adding topics and adding ideas. This is instead of the + buttons on the 
    // container views for those types, which are absurdly hard to hit on an actual ipad.
    addIdeaButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    addIdeaButton.frame = CGRectMake(44, 487, 290, 50);
    addIdeaButton.backgroundColor = [UIColor clearColor];
    [addIdeaButton setTitle:@"Add Idea" forState: UIControlStateNormal];
    addIdeaButton.titleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
    [addIdeaButton addTarget:self action:@selector(addIdeaButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
    [addIdeaButton setEnabled: YES];
    
    addIdeaButton.backgroundColor = [UIColor blackColor];
    addIdeaButton.transform = CGAffineTransformMakeRotation(M_PI/2);
    
    [self.view addSubview:addIdeaButton];

    
    addTopicButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    addTopicButton.frame = CGRectMake(-10, 487, 290, 50);
    addTopicButton.backgroundColor = [UIColor clearColor];
    [addTopicButton setTitle:@"Add Topic" forState: UIControlStateNormal];
    addTopicButton.titleLabel.font = [UIFont boldSystemFontOfSize:24.0f];
    [addTopicButton addTarget:self action:@selector(addTopicButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
    [addTopicButton setEnabled: YES];
    
    addTopicButton.backgroundColor = [UIColor blackColor];
    addTopicButton.transform = CGAffineTransformMakeRotation(M_PI/2);
    
    [self.view addSubview:addTopicButton];
    
    
    // Set up the two popover controllers.
    addIdeaController = [[AddItemController alloc] initWithPlaceholder:@"new idea" withButtonText:@"Add Idea"];
    addIdeaController.delegate = self;
    
    addIdeaPopoverController = [[UIPopoverController alloc] initWithContentViewController:addIdeaController];
    [addIdeaPopoverController setPopoverContentSize:CGSizeMake(300, 100)];

    addTopicController = [[AddItemController alloc] initWithPlaceholder:@"new topic" withButtonText:@"Add Topic"];
    addTopicController.delegate = self;
    
    addTopicPopoverController = [[UIPopoverController alloc] initWithContentViewController:addTopicController];
    [addTopicPopoverController setPopoverContentSize:CGSizeMake(300, 100)];
    
    
//    SetUserButton *setUserButton = [[SetUserButton alloc] init];
//    setUserButton.center = CGPointMake(30, 945);
//    [self.view addSubview:setUserButton];
    
    
    
    [self.view bringSubviewToFront:currentTopicView];
    
    [self initUsers];
    [self initTasks];
    [self initTopics];
    
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
                                                withType:[Meeting class]];
            
            NSLog(@"User left a location, and the meeting view control got notice of it.");
            
            if([curMeeting.locations containsObject:location]) {
                User *user = (User *)[state getObjWithUUID:event.actorUUID withType:[User class]];
                [self removeUserViewForUser:user];
            }
            
            [[location getView] setNeedsDisplay];
            
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
                    
            break;
            
        case kLOCATION_LEFT_MEETING:
            // If it's a location 
            location = (Location *)[state getObjWithUUID:event.actorUUID withType:[Location class]];

            if([curMeeting.locations containsObject:location]) {
                NSLog(@"Location in this meeting left it!");

                for(User *user in location.users) {
                    [self removeUserViewForUser:user];
                }
            }
            
            // Remove the location object from the display, too.
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
            break;
            
        case kUPDATE_TOPIC:
            [topicContainer setNeedsLayout];
            
            [currentTopicView setTopic:[state.meeting getCurrentTopic]];
            
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
        case kUSER_JOINED_LOCATION:
        case kUSER_LEFT_LOCATION:
        case kUPDATE_TOPIC:
        case kNEW_TASK:
        case kASSIGN_TASK:
        case kNEW_TOPIC:
            NSLog(@"...");
            EventView *eventView = [[EventView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) withEvent:event];
            NSLog(@"made the event view");
            [timelineView addEventView:eventView];
            NSLog(@"added it to the timeline view");
            [timelineView setNeedsLayout];
            [timelineView setNeedsDisplay];
            
            break;
    }
    
    
    
}

- (void) addIdeaButtonPressed:(id) sender {
    NSLog(@"In ADD IDEA BUTTON PRESSED.");
    [addIdeaPopoverController presentPopoverFromRect:addIdeaButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
}

- (void) addTopicButtonPressed:(id) sender {
    NSLog(@"In ADD TOPIC BUTTON PRESSED.");
    [addTopicPopoverController presentPopoverFromRect:addTopicButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];    
}


- (void) itemSubmittedWithText:(NSString *)text fromController:(UIViewController *)controller {

    NSLog(@"item submitted! text: %@ fromController: %@", text, controller);
    
    if(controller == (UIViewController *)addIdeaController) {
        [addIdeaPopoverController dismissPopoverAnimated:true];
        [[ConnectionManager sharedInstance] addTaskWithText:text isInPool:false isCreatedBy:nil isAssignedBy:nil withColor:nil];
    } else if (controller == (UIViewController *)addTopicController) {
        [addTopicPopoverController dismissPopoverAnimated:true];
        [[ConnectionManager sharedInstance] addTopicWithText:text];        
    }
}

- (void) userTaskDrawerExtended:(UserView *)extendedView {
    
    // Loop through all our subviews and look for ones that are UserViews. 
    // Send a message to all of them (except the one that actually extended)
    // to retract their own trask drawer.
    
    for (UserView *view in [UserView getAllUserViews]) {
            if(view != extendedView) {
                [view setDrawerExtended:false];
        }
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
    

    // Debugging to make sure sorting is working properly.
    NSLog(@"laying out users:");
    for(UserView *view in sortedUserViews) {
        NSLog(@"%@", [view getUser]);
    }
    
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
        
        view.side = [sidesList objectAtIndex:viewIndex];
        
        [view wasLaidOut];
        
        viewIndex++;
    }   
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


- (void)dealloc {
    [super dealloc];
    [self.view release];
    
    [users release];
    [tasks release];
    
    [taskViews release];
    
    [queue release];
    
    [clock invalidate];
}




#pragma mark Internal Methods

- (void)clk {
    [meetingTimerView clk];
    [topicContainer setNeedsDisplay];
    [currentTopicView setNeedsDisplay];
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
