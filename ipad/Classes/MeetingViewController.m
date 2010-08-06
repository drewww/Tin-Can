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
    participantsContainer = [[UIView alloc] initWithFrame:self.view.frame];
    [participantsContainer retain];
    [self.view addSubview:participantsContainer];
        
    [self initParticipantsView];
    [self initTodoViews];
    
	TaskContainerView *tasksContainer=[[TaskContainerView alloc] initWithFrame:CGRectMake(260, -65, 250, 600) ];

	[self.view addSubview:tasksContainer];	
	
    [[DragManager sharedInstance] initWithRootView:self.view withParticipantsContainer:participantsContainer];

    [self.view bringSubviewToFront:participantsContainer];
	[self.view bringSubviewToFront:meetingTimerView];
    [self.view bringSubviewToFront:tasksContainer];
    queue = [[[NSOperationQueue alloc] init] retain];

    lastRevision = INITIAL_REVISION_NUMBER;
    
    NSLog(@"Done loading view.");
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
-(NSMutableArray *)getParticpantLocationsForNumberOfPeople:(int)totalNumberOfPeople{    
	int i = 0;
	int arrayCounter=0;
	int sideLimit= ceil(totalNumberOfPeople/4.0);
	int topLimit=trunc(totalNumberOfPeople/4.0);
	NSLog(@"Sides:%d", sideLimit);
	NSLog(@"points:%d", topLimit);
	//assigns number of participants to a side
	NSMutableArray *sides=[[NSMutableArray arrayWithObjects:[NSNumber numberWithInt: 0],[NSNumber numberWithInt:0],
							[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],nil]retain];
	
	while (i<totalNumberOfPeople) {
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
	NSMutableArray *points=[[NSMutableArray alloc] initWithCapacity:totalNumberOfPeople];
	NSMutableArray *rotations=[[NSMutableArray alloc] initWithCapacity:totalNumberOfPeople];
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
	NSMutableArray *position=[[NSMutableArray alloc] initWithCapacity:2];
	[position addObject:points];
	[position addObject:rotations];
	NSLog(@"Sides:%@", sides);
	NSLog(@"points:%@", points);
	return position;
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
    
	NSMutableArray *position= [self getParticpantLocationsForNumberOfPeople:[names count]];
	
	
	
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
        
        
        
        
        
        newUserView.center = [[[position objectAtIndex:0] objectAtIndex:i]CGPointValue];
        
        //NSLog(@"center: %f,%f", newUserView.center.x, newUserView.center.y);
        
        
        // This is used for debugging the entire layout by pushing users off the edge so you can see
        // the entire view.
//        newUserView.center = CGPointMake(newUserView.center.x + 100, newUserView.center.y + 100);

//        CGRect newFrame = CGRectMake(origin.x, origin.y, newUserView.frame.size.width, newUserView.frame.size.width);
        
//        newUserView.frame = newFrame;
        
        CGFloat rot = [[[position objectAtIndex:1] objectAtIndex:i]floatValue];
        [newUserView setTransform:CGAffineTransformMakeRotation(rot)];
        
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
