//
//  MeetingViewController.m
//  TinCan
//
//  Created by Drew Harry on 5/10/10.
//  Copyright MIT Media Lab 2010. All rights reserved.
//

#import "MeetingViewController.h"
#import "ParticipantView.h"
#import "TodoUpdateOperation.h"
#import "Todo.h"
#import "Participant.h"
#import "TodoItemView.h"
#import "DragManager.h"
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
    [[DragManager sharedInstance] initWithRootView:self.view withParticipantsContainer:participantsContainer];

	[self.view bringSubviewToFront:meetingTimerView];
    [self.view bringSubviewToFront:participantsContainer];
    [self.view bringSubviewToFront:taskContainer];
	[self.view bringSubviewToFront:topicContainer];
	[self.view bringSubviewToFront:locContainer];

    queue = [[[NSOperationQueue alloc] init] retain];

    lastRevision = INITIAL_REVISION_NUMBER;
    
    [self initUsers];
    [self initTasks];
    
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
    [queue addOperation:[[TodoUpdateOperation alloc] initWithViewController:self withRevisionNumber:INITIAL_REVISION_NUMBER]];
    
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
            
            if([curMeeting.locations containsObject:location]) {
                User *user = (User *)[state getObjWithUUID:event.actorUUID withType:[User class]];
                [[user getView] removeFromSuperview];
            }
            
        break;
           
            
        case kUSER_JOINED_LOCATION:
            // If it's a location in our meeting, 
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
            break;
            
        case kLOCATION_JOINED_MEETING:
            location = (Location *)[state getObjWithUUID:event.actorUUID withType:[Location class]];
            
            if([curMeeting.locations containsObject:location]) {
                NSLog(@"another location joined this meeting! with users: %@", location.users);
                for(User *user in location.users) {
                    [participantsContainer addSubview:[user getView]];
                }
            }
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

// TODO Nuke this function. Doesn't make much sense now that we're not hardcoding anymore.
- (void)initTodoViews {
    todoViews = [[NSMutableSet set] retain];
    todos = [[NSMutableDictionary dictionary] retain];    
}

// Should this operate on the Todo level or TodoItemView? I like Todo better,
// but since there's that initWithText sugar, they're equally easy to 
// do right now. TODO refactor this later.
- (void)addTodo:(Todo *)todo {
     
    TodoItemView *view = [[TodoItemView alloc] initWithTodo:todo atPoint:[self getNextTodoPosition] isOriginPoint:true fromParticipant:[participants objectForKey:todo.creatorUUID] useParticipantRotation:false withColor:[UIColor whiteColor]];

    [todos setObject:todo forKey:todo.uuid];

    [todoViews addObject:view];

    [self.view addSubview:view];
    [view setNeedsDisplay];
}


- (CGPoint) getNextTodoPosition {
    // Place todos in a column on the left side of the display, and move down
    // the list as todos are added. 
    return CGPointMake(600 - 40*[todos count], 115);
}


#pragma mark Communication Handling

// NEW_TODO todo_id user_id todo_text
- (void)handleNewTodoWithArguments:(NSArray *)args {

    // Check for the right argument count first.
    // TODO need some kind of error handling here. Not sure how to do
    // that nicely in obj c yet.
    if ([args count] < 4) {
        NSLog(@"Tried to handle a new todo message, but it didn't have enough args: %@", args);
        return;
    }

    NSLog(@"valid number of arguments: %@", args);
    
    // Split up the arguments.
    NSString *todoId = [args objectAtIndex:1];
    NSString *userId = [args objectAtIndex:2];
    
    // Need to construct an array that's just the back 3:end of the original.
    // This should be easy, but it's not AFAICT.
    NSRange textComponents = NSMakeRange(3, [args count]-3);
    NSString *todoText = [[args subarrayWithRange:textComponents] componentsJoinedByString:@" "];
    
    NSLog(@"NEW_TODO: from %@, with id %@ and text '%@'", todoId, userId, todoText);
    
    // This is a trivial implementation - this should really split the data
    // field up and decide based on commands. But for now...
    Todo *newTodo = [[Todo alloc] initWithText:todoText withCreator:userId withUUID:todoId];
    
    // TODO move this all into a proper init sequence - there should be
    // no way to create a todo and not register it with the todo store.
    // Really, I need to make a singleton data manager and have
    // everyone interact with that on init.    
    [self addTodo:newTodo];    
}

// ASSIGN_TODO todo_id user_id
// user_id=-1 means deassign the todo from everyone
- (void)handleAssignTodoWithArguments:(NSArray *)args {
    if ([args count] != 3) {
        NSLog(@"Received ASSIGN_TODO with inappropriate number of arguments: %@", args);
        return;        
    }
    
    NSLog(@"ASSIGN TODO participant retain count: %d", [participants retainCount]);
    
    NSString *todoId = [args objectAtIndex:1];
    NSString *assignedUserId = [args objectAtIndex:2];
    
    // Now get the todo object and the assigned user object.
    NSLog(@"todoId %@", todoId);
    
    Todo *todo = [todos objectForKey:todoId];
    Participant *participant = [participants objectForKey:assignedUserId];
    
    [todo startAssignment:participant withViewController:self];
}


- (void)dispatchTodoCommandString:(NSString *)operation fromRevision:(int)revision{

    // First, grab the revision number.
    // If no revision is set (ie the previous request timed out and didn't return one)
    // grab the saved revision number and use that for the next operation.
    // Otherwise, we got good data and should save the revision number.
    if(revision==-1) {
        revision = lastRevision;
    }
    // This covers the case when the very first query times out. Just keep
    // the revision number at the initial value to wait for the first message
    // from the server.
    else if (revision == -1 && lastRevision == INITIAL_REVISION_NUMBER) {
        revision = INITIAL_REVISION_NUMBER;
    }
    else {
        lastRevision = revision;
    }

    NSLog(@"returned revision number: %d", revision);
            
    // Trying to do this at the top - hopefully this doesn't clog
    // the queue or anything? But it needs to be before any exception
    // handling, so exceptions don't break the update cycle like they
    // were when I had it at the end.
    [queue addOperation:[[TodoUpdateOperation alloc] initWithViewController:self withRevisionNumber:(revision+1)]];
    if (operation == nil) {
        return;
    }


    // Do a little dispatch / handling here where we look for the command
    // code and then parse the arguments appropriately.
    
    // TODO properly handle message with no spaces in them - they seem to 
    // die in a terrible way right now.
    
    // TODO switch this over to a fully JSON structure, instead of this
    // shitty space-delimited format I'm using now. 
    NSArray *commandParts = [operation componentsSeparatedByString:@" "];
    
    // Ignore if it doesn't have at least three parts (the current
    // minimum number of arguments for a command)
    if([commandParts count] >= 3)  {        
        NSString *opCode = [commandParts objectAtIndex:0];
        NSLog(@"opCode: %@", opCode);
        if([opCode isEqualToString:@"NEW_TODO"]) {
            NSLog(@"about to drop into handleNewTodo");
            [self handleNewTodoWithArguments:commandParts];
        } else if ([opCode isEqualToString:@"ASSIGN_TODO"]) {
            [self handleAssignTodoWithArguments:commandParts];        
        } else {
            NSLog(@"Received unknown opCode: %@", opCode);
        }
    }
    
    // Now kick off a new update operation. Since these are
    // long polling, we should only do this exactly as often
    // as we're getting events from toqbot.
    NSLog(@"Enqueing a new update operation...");
}


@end
