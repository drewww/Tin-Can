//
//  MeetingViewController.m
//  TinCan
//
//  Created by Drew Harry on 5/10/10.
//  Copyright MIT Media Lab 2010. All rights reserved.
//

#import "MeetingViewController.h"
#import "TaskView.h"
#import "TaskContainerView.h"
#import "UserView.h"
#import "StateManager.h"
#import "TopicContainerView.h"
#import "ConnectionManager.h"
#import "Event.h"
#import "Location.h"
#import "UserContainer.h"

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
    
    NSDate *startingTime = [NSDate date];
    NSLog(@"starting time in seconds: %f", [startingTime timeIntervalSince1970]);
    NSTimeInterval startingTimeInSeconds = [startingTime timeIntervalSince1970];//-1800;
    
    meetingTimerView = [[MeetingTimerView alloc] initWithFrame:CGRectMake(200, 200, 200, 200) withStartTime:[NSDate dateWithTimeIntervalSince1970:startingTimeInSeconds]];
    [meetingTimerView retain];
    [self.view addSubview:meetingTimerView];
	
					 
    // Create the participants view.
    participantsContainer = [[UserContainer alloc] initWithFrame:self.view.frame];
    [participantsContainer retain];
    [self.view addSubview:participantsContainer];
            
	taskContainer=[[TaskContainerView alloc] initWithFrame:CGRectMake(260, -65, 250, 600) withRot: M_PI/2];

	topicContainer=[[TopicContainerView alloc] initWithFrame:CGRectMake(260, 490, 250, 600)];
	
	locContainer=[[LocationContainerView alloc] initWithFrame:CGRectMake(20, 432, 290, 160)];
	
	[self.view addSubview:taskContainer];	
	[self.view addSubview:topicContainer];
	[self.view addSubview:locContainer];

    //[[DragManager sharedInstance] initWithRootView:self.view withParticipantsContainer:participantsContainer];

	[self.view bringSubviewToFront:meetingTimerView];
    [self.view bringSubviewToFront:participantsContainer];
    [self.view bringSubviewToFront:taskContainer];
	[self.view bringSubviewToFront:topicContainer];
	//[self.view bringSubviewToFront:locContainer];

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
                [[user getView] removeFromSuperview];
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
                [participantsContainer addSubview:[user getView]];
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
                    [[user getView] removeFromSuperview];
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
                    [participantsContainer addSubview:[user getView]];
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
    [participantsContainer release];
    participantsContainer = nil;
    
    [meetingTimerView release];
    meetingTimerView = nil;
}


- (void)dealloc {
    [super dealloc];
    [self.view release];
    
    [participantsContainer release];
    
    [participants release];
    [todos release];
    
    [todoViews release];
    
    [queue release];
    
    [clock invalidate];
}




#pragma mark Internal Methods

- (void)clk {
    [meetingTimerView setNeedsDisplay];
}   


- (void) initUsers {
    // Ask the state manager for all the users, and make views for them.
    
    int i=0;
    for(User *user in [StateManager sharedInstance].meeting.currentParticipants) {
        NSLog(@"Creating UserView for user: %@", user);
        
        // The user knows how to construct its own view if it doesn't have one yet. 
        // This will avoid double-creating if for some reason someone else needs the User's view.
        UserView *view = (UserView *)[user getView];//changed UIView to UserView to get rid of yellow error
        
        [participantsContainer addSubview:view];
        
        [view setNeedsDisplay];
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


- (void)initParticipantsView {
	
	
    
    participants = [[NSMutableDictionary dictionary] retain];
        
    // Make a set of names.
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:10];
    [names addObject:@"Matt"];
    [names addObject:@"Andrea"];
    [names addObject:@"Jaewoo"];
    [names addObject:@"Charlie"];
    [names addObject:@"Chris"];
    [names addObject:@"Paula"];
    [names addObject:@"Ig-Jae"];
    [names addObject:@"Trevor"];
    [names addObject:@"Paulina"];
    [names addObject:@"Dori"];
    
	int i = 0;
	
	for (NSString *name in names) {
        // This is going to get really ugly for now, since we don't
        // have a nice participant layout manager. Just hardcode
        // positions.
        UIColor *color;
        NSString *uuid;
        switch(i) {
            case 0:
                
                color = [UIColor redColor];
                uuid = @"e124824b-13c1-4357-b901-cd69a289c8ab";
                break;
            case 1:
                color = [UIColor redColor];
                uuid = @"844e0960-513b-44f2-9540-07356c827750";
                break;
            case 2:
               
                color = [UIColor redColor];
                uuid = @"6b23a18d-a134-4507-a546-5f567ef3226a";
                break;
            case 3:
				color = [UIColor blueColor];
                uuid = @"1d9ae851-c555-493f-957b-a2ff8badfe99";
                break;
            case 4:
                color = [UIColor blueColor];
                uuid = @"62c76fb7-efd8-46fa-ae03-b1c694f620f8";
                break;
            case 5:
                color = [UIColor blueColor];
                uuid = @"c1c47f73-4fba-46e4-b005-014ef81676f9";
                break;
            case 6:
                color = [UIColor yellowColor];
                uuid = @"9ae23576-c7a9-4e6d-96b6-b00fd928e049";
                break;
            case 7:
                color = [UIColor yellowColor];
                uuid = @"f0748716-7553-45d6-867d-ddcbe27dd04c";
                break;
            case 8:
                color = [UIColor greenColor];
                uuid = @"384f2c76-59d8-4561-b6ed-8c1bf0d3b721";
                break;
            case 9:        
                color = [UIColor purpleColor];
                uuid = @"15318475-e45d-4384-a875-9d2147afec3d";
                break;
        }
        
        //Participant *p = [[Participant alloc] initWithName:name withUUID:uuid];

        User *u = [[User alloc] initWithUUID:uuid withName:name withLocationUUID:nil];
        
        [participants setObject:u forKey:u.uuid];
        
        // Now make the matching view.
        UserView *newUserView = [[UserView alloc] initWithUser:u];
        
        
        
        
        
        //newUserView.center = [[[position objectAtIndex:0] objectAtIndex:i]CGPointValue];
        
        //NSLog(@"center: %f,%f", newUserView.center.x, newUserView.center.y);
        
        
        // This is used for debugging the entire layout by pushing users off the edge so you can see
        // the entire view.
//        newUserView.center = CGPointMake(newUserView.center.x + 100, newUserView.center.y + 100);

//        CGRect newFrame = CGRectMake(origin.x, origin.y, newUserView.frame.size.width, newUserView.frame.size.width);
        
//        newUserView.frame = newFrame;
        
       // CGFloat rot = [[[position objectAtIndex:1] objectAtIndex:i]floatValue];
//        [newUserView setTransform:CGAffineTransformMakeRotation(rot)];
//        
//        p.view = newParticipantView;
        [participantsContainer addSubview:newUserView];
        [participantsContainer bringSubviewToFront:newUserView];
        [newUserView setNeedsDisplay];
        i++;
    }
}


#pragma mark Communication Handling


@end
