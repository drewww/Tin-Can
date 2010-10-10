//
//  MeetingViewController.m
//  TinCan
//
//  Created by Drew Harry on 5/10/10.
//  Copyright MIT Media Lab 2010. All rights reserved.
//

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

#define INITIAL_REVISION_NUMBER 10000

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
	
	taskContainer=[[TaskContainerView alloc] initWithFrame:CGRectMake(260, -65, 250, 600) withRot: M_PI/2];

	topicContainer=[[TopicContainerView alloc] initWithFrame:CGRectMake(260, 490, 250, 600)];
	
	locContainer=[[LocationContainerView alloc] initWithFrame:CGRectMake(20, 432, 290, 160)];
	
	[self.view addSubview:taskContainer];	
	[self.view addSubview:topicContainer];
	[self.view addSubview:locContainer];

    [[DragManager sharedInstance] setRootView:self.view andTaskContainer:taskContainer];

	[self.view bringSubviewToFront:meetingTimerView];
    [self.view bringSubviewToFront:taskContainer];
	[self.view bringSubviewToFront:topicContainer];

    queue = [[[NSOperationQueue alloc] init] retain];

    lastRevision = INITIAL_REVISION_NUMBER;
    
    [self initUsers];
    [self initTasks];
    [self initTopics];
    
    NSLog(@"Done loading view.");
    
    
    // Now register as an event listener on the ConnectionManager, so we can update
    // the view in response to changes.
    [[ConnectionManager sharedInstance] addListener:self];
    
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
            [locContainer addSubview:[location getView]];
            
            break;
            
        case kNEW_TOPIC:
            NSLog(@"adding new topic");
            // Add the topic to the topic list.
            [topicContainer addSubview:[[event.results objectForKey:@"topic"] getView]];
            break;
            
        case kUPDATE_TOPIC:
            break;
            
        case kNEW_TASK:
            NSLog(@"adding new task to the task container.");
            [taskContainer addSubview:[[event.results objectForKey:@"task"] getView]];
            break;
            
        case kDELETE_TASK:
            break;
            
        case kEDIT_TASK:
            break;
            
        case kASSIGN_TASK:
            NSLog(@"assigning tasks in the meeting view controller because I'm a bad person");
            
            Task *task = (Task *)[state getObjWithUUID:[event.params objectForKey:@"taskUUID"] withType:[Task class]];
            
            NSLog(@"in assign task handler");
            
            Actor *assignedBy = (Actor *)[state getObjWithUUID:event.actorUUID withType:[Actor class]];
            NSDate *assignedAt = [NSDate dateWithTimeIntervalSince1970:[[event.params objectForKey:@"assignedAt"] doubleValue]];
            
            // TODO Check this execution path! I don't have a way to do deassignment quite yet. 
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
            
        default:
            NSLog(@"Received an unknown event type: %d", event.type);
            break;
    }
}

- (void) addUserViewForUser:(User *)newUser {
    [self.view addSubview:[newUser getView]];
    [self.view bringSubviewToFront:[newUser getView]];
    
    [self layoutUsers];
}

- (void) removeUserViewForUser:(User *)leavingUser {
    [[leavingUser getView] removeFromSuperview];
    [self layoutUsers];
}

- (void) layoutUsers {
    
    NSSet *allUserViews = [[UserView getAllUserViews] retain];
    int numViews = [allUserViews count];
    
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
    //Forms points from side assignments
    NSMutableArray *points=[[NSMutableArray alloc] initWithCapacity:numViews];
    NSMutableArray *rotations=[[NSMutableArray alloc] initWithCapacity:numViews];
    for (i=0; i<4; i++) {
        int c =1;
        while (c<=[[sides objectAtIndex:i] intValue]) {
            if (i==0|| i==2) {
                float divisions=1024.0/[[sides objectAtIndex:i] intValue];
                float yVal= (divisions*c) -(divisions/2.0);
                if (i==0) {
                    [points addObject:[NSValue valueWithCGPoint:CGPointMake(0, yVal)]];
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
                    [points addObject:[NSValue valueWithCGPoint:CGPointMake(xVal, 1024)]];
                    [rotations addObject:[NSNumber numberWithFloat:0.0]];
                }
            }
            c++;
        }
    }
    // Now that we've done all the layout math, put everything in its place.
    int viewIndex = 0;
    
    for(UIView *view in allUserViews) {
        view.center = [[points objectAtIndex:viewIndex] CGPointValue];
              
        [view setTransform:CGAffineTransformMakeRotation([[rotations objectAtIndex:viewIndex] floatValue])];
        
        viewIndex++;
    }   
    
    [allUserViews release];
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
        [taskContainer addSubview:[task getView]];
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
        [topicContainer addSubview:[topic getView]];
    }
    
    [topicContainer setNeedsLayout];
    
    [topics release];
}


#pragma mark Communication Handling


@end
