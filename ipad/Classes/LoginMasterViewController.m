//
//  LoginMasterViewController.m
//  Login
//
//  Created by Paula Jacobs on 6/29/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LoginMasterViewController.h"
#import "LoginAppDelegate.h"
#import "LogoView.h"
#import "LocationViewController.h"
#import "RoomViewController.h"
#import "headerView.h"
#import "TinCanViewController.h"
#import "MeetingViewController.h"
#import "StateManager.h"
#import "ConnectionManager.h"
#import "Location.h"
#import "WebViewController.h"

@class TinCanViewController;

#define ROOM_INDEX 0
#define USER_INDEX 1

#define FRAME_OFFSET 600

@implementation LoginMasterViewController
- (id)initWithController:(TinCanViewController *)control{
	if ((self = [super init])) {
        
        controller=control;
        //NSLog(@"is being called with %@:", controller);
		
	} 
	return self;
    
}
- (void) handleConnectionEvent:(Event *)event {
	NSLog(@"Received event: %d", event.type);
	
	
	if(event.type==kGET_STATE_COMPLETE) {
        // Triggers when the login view is loading. Basically, once you hit connect on the previous
        // server select screen, a get state request is sent out. We need all that information from
        // the server to construct this screen, so we block on setting this screen up until we
        // have all the pieces we need.
        
		// Elements in the Login page (Our Logo, Our Location Table and Our Room Table)
		LogoView *picView= [[[LogoView alloc] initWithImage:[UIImage imageNamed:@"full_logo.png"] 
												  withFrame: CGRectMake(self.view.frame.size.width/2.0-250, 700, 500, 500) ] retain];
		
		roomViewController = [[[RoomViewController alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-200,self.view.frame.size.height/2.0-250, 400,500) withController:self] retain];
		
		locViewController = [[[LocationViewController alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-200,self.view.frame.size.height/2.0-250+600, 400,500) withController:self] retain];
		        
        // Make a bonus user view controller that we can add and hide, to be swapped in based on the 
        // user/location switch. 
        userViewController = [[[UserViewController alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-200,self.view.frame.size.height/2.0-250+600, 400,500) withController:self] retain]; 
        userViewController.view.hidden = TRUE;
        
        // Make a UI switch to toggle between user and location modes for login.
        actorTypeToggle = [[UISegmentedControl alloc] initWithItems:nil];
        [actorTypeToggle insertSegmentWithTitle:@"Room" atIndex:ROOM_INDEX animated:NO];
        [actorTypeToggle insertSegmentWithTitle:@"User" atIndex:USER_INDEX animated:NO];
        actorTypeToggle.selectedSegmentIndex = ROOM_INDEX;
		actorTypeToggle.transform = CGAffineTransformMakeRotation(M_PI_2);
//        actorTypeToggle.center = CGPointMake(userViewController.view.center.x + userViewController.view.frame.size.width/2 + 50, userViewController.view.center.y);
        actorTypeToggle.frame = CGRectMake(self.view.frame.size.width/2.0+250,self.view.frame.size.height/2.0+400, 60,400);
        actorTypeToggle.momentary = NO;

        [actorTypeToggle setEnabled:true];

        
        [actorTypeToggle addTarget:self action:@selector(actorTypeToggled:) forControlEvents:UIControlEventValueChanged];
        
		// Initializes Login Button
		loginButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
		[loginButton setTransform:CGAffineTransformMakeRotation(M_PI/2)];
		loginButton.frame = CGRectMake(self.view.frame.size.width/2.0-200+150,self.view.frame.size.height/2.0-250+600+475, 100,150);
		loginButton.backgroundColor = [UIColor clearColor];
		[loginButton setTitle:@"Login" forState: UIControlStateNormal];
		[loginButton setFont:[UIFont boldSystemFontOfSize:30.0f]];
		[loginButton addTarget:self action:@selector(loginButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
		[loginButton setEnabled: NO];
		
		// Disabled Settings for Login Button
		
		if( loginButton.enabled==NO){
			
			// sets user intructions for login
			loginInstructions = [[UILabel alloc]
								 initWithFrame:CGRectMake(self.view.frame.size.width/2.0-50-100,self.view.frame.size.height/2.0-250+600+250, 150,600)];
			[loginInstructions setTransform:CGAffineTransformMakeRotation(M_PI/2)];
			loginInstructions.text = @" ";
			loginInstructions.numberOfLines = 2;
			loginInstructions.textAlignment = UITextAlignmentCenter;
			loginInstructions.textColor = [UIColor whiteColor];
			loginInstructions.backgroundColor = [UIColor clearColor];
			loginInstructions.font = [UIFont boldSystemFontOfSize:20.0f];
			[self.view addSubview:loginInstructions];
			
		}
		
		// Headers
		HeaderView *headerRoom =[[[HeaderView alloc] 
                                  initWithFrame:CGRectMake(self.view.frame.size.width/2.0+80,self.view.frame.size.height/2.0-30, 400,60) withTitle:@"Meetings"] retain];
		headerLocation = [[[HeaderView alloc] 
                                      initWithFrame:CGRectMake(self.view.frame.size.width/2.0+80,self.view.frame.size.height/2.0+600-30, 400,60) withTitle:@"Rooms"] retain];
        headerLocation.hidden = TRUE;
        
        chosenRoom = nil;
        chosenLocation = nil;
        chosenUser = nil;
        
        fourthPosition = false;
        
		// Add Elements to View
		//[self.view addSubview:wvTutorial];
		[self.view addSubview:picView];
		[self.view addSubview:loginButton];
		[self.view addSubview:roomInstructions];
		[self.view addSubview:locationInstructions];
		[self.view addSubview:locViewController.view];
		[self.view addSubview:roomViewController.view];
        [self.view addSubview:userViewController.view];
        [self.view addSubview:actorTypeToggle];
		[self.view addSubview:headerLocation];
		[self.view addSubview:headerRoom];
		[self.view setNeedsDisplay];
        
	} else if (event.type==kADD_ACTOR_DEVICE) {
        NSLog(@"In ADD_ACTOR_DEVICE callback.");
        
        // There are two ways this can happen - if we're joining as a user, then we need
        // to join a location here. Once we've joined the location, then join the meeting. 
        // We can't join the meeting right away, though - we need to wait for the message
        // from the server confirmation that the user has joined the location first.
        
        if(actorTypeToggle.selectedSegmentIndex == USER_INDEX) {
            [[ConnectionManager sharedInstance] joinLocation:chosenLocation withUser:[StateManager sharedInstance].user];
        } else {
            [[ConnectionManager sharedInstance] joinRoomWithUUID:chosenRoom.uuid];
        }
        
    } else if (event.type==kUSER_JOINED_LOCATION) {
        // This will only trigger in the join-as-user case, so no need for an if statement here.
        [[ConnectionManager sharedInstance] joinRoomWithUUID:chosenRoom.uuid];

        // After this point, we'll be back on the normal path, and LOCATION_JOINED_MEETING
        // will trigger and we'll be all set to login as normal.
        
    } else if (event.type==kLOCATION_JOINED_MEETING) {
        
        NSLog(@"LOCATION_JOINED_MEETING");
        // This is dangerous. Multiple presses will create multiple view controllers, and this view
        // controller is never going to get released. Really need to find a nicer way to do this.
        // Controllers should be owned by the TinCanViewController, perhaps, and not
        // created by people trying to switch into something specific. 
        
        NSLog(@"Would normally be switching viewcontrollers now, but not going to.");
        
        // Deregister ourselves for server messages.
        [[ConnectionManager sharedInstance] removeListener:self];
        
        [controller switchToViewController:[[[MeetingViewController alloc] init] retain]];        
    } else if (event.type==kCONNECTION_REQUEST_FAILED) {
        connectionInfoLabel.text = [NSString stringWithFormat:@"Could not connect to '%@'. The server is down.", [ConnectionManager sharedInstance].server];        
        
        [self.view addSubview:connectionInfoLabel];
    } else if (event.type == kCONNECTION_STATE_CHANGED) {
        
        // Check and see if we're disconnected now.
        if([[ConnectionManager sharedInstance].serverReachability currentReachabilityStatus]==NotReachable) {
            connectionInfoLabel.text = [NSString stringWithFormat:@"Lost wireless connectivity.", [ConnectionManager sharedInstance].server];                    
            [self.view addSubview:connectionInfoLabel];
        }
    }
    
	if(self.view != nil) {
		NSLog(@"calling reload data:");
		[locViewController update];
		[roomViewController update];
	}
	
    
}		
- (void)loadView {
	
	//NSLog(@"View is being called");
	// Initializers
	// Sets the frame and then sets the center of the view to be at the location our our Logo.
	// The currentPage variable tracks which part of the view the user is seeing
	ConnectionManager *conMan = [ConnectionManager sharedInstance];
	[conMan addListener:self];
    
	self.view = [[UIView alloc] initWithFrame:CGRectMake(0,0, 700.0, 3200.0) ];
	self.view.center= CGPointMake(768/2.0, 1024/2.0+600);
	[self.view setBackgroundColor:[UIColor blackColor]]; 
	currentPage=0;
    
	// Tracks user selections
	chosenRoom=NULL;
	chosenLocation=NULL;
    
    connectionInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-200, 325, 350, 200)];
    [connectionInfoLabel setTransform:CGAffineTransformMakeRotation(M_PI/2)];
    connectionInfoLabel.numberOfLines = 3;
    connectionInfoLabel.textAlignment = UITextAlignmentCenter;
    connectionInfoLabel.textColor = [UIColor whiteColor];
    connectionInfoLabel.backgroundColor = [UIColor colorWithRed:0.5 green:0.3 blue:0.3 alpha:1.0];
    connectionInfoLabel.font = [UIFont boldSystemFontOfSize:30.0f];
    connectionInfoLabel.layer.cornerRadius = 8;
    
    if([conMan.serverReachability currentReachabilityStatus]==NotReachable) {
        // put up a UI notification that we can't start because the network
        // connection is down.
        connectionInfoLabel.text = [NSString stringWithFormat:@"Could not reach server '%@'. Wireless is not connected.", SERVER];        
        [self.view addSubview:connectionInfoLabel];
        
    } else {
        // we can see the server, so we're all good. 
        [conMan getState];
    }
}

// Dictates what action to take when a User makes a selection
- (void) loginButtonPressed:(id)sender{
    // Turn off the button immediately to avoid double presses.
    [self setLoginButtonEnabled:false];
	
	NSLog(@"Login button pressed.");
    NSLog(@"location: %@; room: %@", chosenLocation, chosenRoom);
    
    ConnectionManager *connMan = [ConnectionManager sharedInstance];


    if (actorTypeToggle.selectedSegmentIndex == USER_INDEX) {
        [connMan setUser:chosenUser.uuid];
    } else {
        [connMan setLocation:chosenLocation.uuid];        
    }
    
    [connMan connect];

    // Now we need to join a room, but we need to block on getting
    // an acknowedgement from the server that we've logged in 
    // successfully. So move this up to the handleConnectionEvent
    // method. First, it's ADD_ACTOR_DEVICE, then
    // LOCATION_JOINED_MEETING.
    
}



- (void) setLoginButtonEnabled:(bool) enabled {
    if(enabled) {
        loginButton.alpha = 1.0;
        loginButton.enabled = true;
    } else {
        loginButton.alpha = 0.6;
        loginButton.enabled = false;
    }
}

// Stores the location the User seleted in chosenLocation then updates login instructions
-(void)chooseLocation:(Location *)loc{
	
	chosenLocation= loc;
    [locViewController setSelectedLocation:loc];
    
    [self updateLoginButton];	
}		


// Stores the room the user seleted in chosenRoom then updates login instructions
-(void)chooseRoom:(Room *)room {
	
	chosenRoom= room;
    
    // Now pass a message to the LocationViewController so it can highlight 
    // physical locations appropropriately.
    [locViewController setSelectedRoom:room];
    
    [self updateLoginButton];    
}	

- (void)chooseUser:(User *)user {
    chosenUser = user;
    
    [userViewController setSelectedUser:user];
    
    if(user.location != nil) {
        [self chooseLocation:user.location];
    }
    
    [self updateLoginButton];
}

- (void) updateLoginButton {
    
    // Looks at the current state of selected room/location and
    // updates the login button and login instruction text
    // appropriately.
    if(chosenRoom != nil && (chosenLocation != nil && actorTypeToggle.selectedSegmentIndex==ROOM_INDEX || (chosenUser!=nil && chosenLocation!=nil))) {
        [self setLoginButtonEnabled:true];
        loginInstructions.text = @"";
    } else if (chosenRoom != nil && chosenLocation==nil && actorTypeToggle.selectedSegmentIndex == ROOM_INDEX) {
        [self setLoginButtonEnabled:false];
        loginInstructions.text = @"Please select a room to join.";
        loginInstructions.numberOfLines = 2;
    } else if (chosenRoom != nil && chosenUser==nil && actorTypeToggle.selectedSegmentIndex == USER_INDEX) {
        [self setLoginButtonEnabled:false];
        loginInstructions.text = @"Please select your name.";
        loginInstructions.numberOfLines = 2;
    } else if (chosenRoom != nil && chosenLocation==nil && actorTypeToggle.selectedSegmentIndex == USER_INDEX) {
        [self setLoginButtonEnabled:false];
        loginInstructions.text = @"Please select a room to join.";
        loginInstructions.numberOfLines = 2;
    } else if (chosenLocation != nil && chosenRoom==nil) {
        [self setLoginButtonEnabled:false];
        loginInstructions.text = @"Please select a meeting to join.";
        loginInstructions.numberOfLines = 2;
    }
}


// Decides what movement to take based on our current location (currentPage) and the size and direction of our stroke (begin-end)
// Then updates the view and the currentPage variable to match those movements
-(void)moveWithBegin:(CGFloat)begin withEnd:(CGFloat)end{
	
    // This whole setup is a bit of a horrorshow. Basically, for each
    // position, we figure out far we've dragged and if it's in certain
    // binned distances, we go to those specific pages. To adapt this to 
    // add a fourth page, we have to add more potential slots in each case.
    
	[UIView beginAnimations:@"move_to_Left" context:NULL];
	[UIView setAnimationDuration:.50f];
	
	if(currentPage==0){
		if( (begin-end)>600){
			self.view.center=CGPointMake(768/2.0,1024/2.0-600);
			currentPage=2;
		}
		else if( (begin-end)>80){
			self.view.center=CGPointMake(768/2.0,1024/2.0);
			currentPage=1;
		}
		else{
			self.view.center=CGPointMake(768/2.0,1024/2.0+600);
			currentPage=0;
		}
        
        // We're going to skip the 0->3 transition because
        // it's just not possible.
	}
    
	else if(currentPage==1){
		if ((begin-end)>80){
			self.view.center=CGPointMake(768/2.0,1024/2.0-600);
			currentPage=2;
		} 
		else if ((begin-end)<-80){
			self.view.center=CGPointMake(768/2.0,1024/2.0+600);
			currentPage=0;
		}
		else{
			self.view.center=CGPointMake(768/2.0,1024/2.0);
			currentPage=1;
		}
        
        // Skip the 1->3 transition for now beacuse I thiiiink
        // it's not possible.
	}
	
	else if (currentPage==2){
		if( (begin-end) <-600){
			self.view.center=CGPointMake(768/2.0,1024/2.0+600);
			currentPage=0;
		}
		else if( (begin-end) <-80){
			self.view.center=CGPointMake(768/2.0,1024/2.0);
			currentPage=1;
		}
		else if ((begin-end) > 80 && fourthPosition) {
			self.view.center=CGPointMake(768/2.0,1024/2.0-1200);
			currentPage=3;
		} else {
			self.view.center=CGPointMake(768/2.0,1024/2.0-600);
			currentPage=2;
        }
	} else if (currentPage==3) {
        if ((begin-end) < -80) {
			self.view.center=CGPointMake(768/2.0,1024/2.0-600);
            currentPage = 2;
        } else {
			self.view.center=CGPointMake(768/2.0,1024/2.0-1200);
			currentPage=3;            
        }
    }
    
	[self.view setNeedsDisplay];	
	[UIView setAnimationDelegate:self.view];
	[UIView commitAnimations];
}

- (void) actorTypeToggled:(id)sender {
    NSLog(@"Got toggle button pressed!");
    
    if(actorTypeToggle.selectedSegmentIndex==USER_INDEX) {
        
        // When we switch into user, we need to fade in the user view
        // and slide over the location view, login button,
        // and login lable. Will also require toggling the number
        // of sticky spots the dragging mechanics have.
        userViewController.view.alpha = 0.0;
        userViewController.view.hidden = FALSE;
        
        headerLocation.hidden = false;
        headerLocation.alpha = 0.0;
       [UIView animateWithDuration:0.5 animations:^{

            userViewController.view.alpha = 1.0;
           headerLocation.alpha = 1.0;
           
            locViewController.view.center = CGPointMake(locViewController.view.center.x, locViewController.view.center.y + FRAME_OFFSET);;
            loginButton.center = CGPointMake(loginButton.center.x, loginButton.center.y + FRAME_OFFSET);
            loginInstructions.center = CGPointMake(loginInstructions.center.x, loginInstructions.center.y + FRAME_OFFSET);
           headerLocation.center = CGPointMake(headerLocation.center.x, headerLocation.center.y + FRAME_OFFSET);
                
        } completion:^(BOOL finished){
            fourthPosition = true;
        }];
        
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            
            locViewController.view.center = CGPointMake(locViewController.view.center.x, locViewController.view.center.y - FRAME_OFFSET);
            loginButton.center = CGPointMake(loginButton.center.x, loginButton.center.y - FRAME_OFFSET);
            loginInstructions.center = CGPointMake(loginInstructions.center.x, loginInstructions.center.y - FRAME_OFFSET);
            headerLocation.center = CGPointMake(headerLocation.center.x, headerLocation.center.y - FRAME_OFFSET);

            
            userViewController.view.alpha = 0.0;
            headerLocation.alpha = 0.0;
        } completion:^(BOOL finished){
            userViewController.view.hidden = TRUE;
            headerLocation.hidden = TRUE;
            fourthPosition = false;
        }];

    }
    
    if(!fourthPosition && currentPage == 3) {
        // Then we need to transition back to the third page, ie page 2. We'll fake
        // a call to movewithbegin for this.
        
        // (actually, this isn't really doable given the visibility when you're on
        // page 3, but I'll leave it in anyway.)
        [self moveWithBegin:0 withEnd:-100];
    }
    
    [self updateLoginButton];
}


// Handling Touches

// When a touch begins, the x coordinate from our current view and the super view behind it is stored
// Only the x coordinate is needed, because our goal is to only allow the user to slide the screen horizontally
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint beginTouch = [touch locationInView:self.view];
	CGPoint beginTouchSuper = [touch locationInView:self.view.superview];
	beginPoint=beginTouch.y;
	beginPointSuper=beginTouchSuper.y;
    
}

// When the user moves there finger to make a swipe, we want the screen to move along with it
// current touch keeps track of where the finger is in our view and then shifts the center of the screen 
// based on the total distance that was moved. 
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint currentTouch= [touch locationInView:self.view];
	currentPoint=currentTouch.y;
	
	
	[UIView beginAnimations:@"move" context:NULL];
	[UIView setAnimationDuration:0.005f];
	
	// If movement is within our range (so they don't go too far off screen), we want to shift the center
	// the and statement allows for negitive direction.
	if((self.view.center.y+(currentPoint-beginPoint)<2201) && (self.view.center.y+(currentPoint-beginPoint)>-800)){
        self.view.center=CGPointMake(self.view.center.x,self.view.center.y+(currentPoint-beginPoint));
	}
	
	
	[self.view setNeedsDisplay];	
	[UIView setAnimationDelegate:self.view];
	[UIView commitAnimations];
	
}


// When a touch ends, we want to calculate the total distanced moved. 
// Because we moved the center of our view, our end point didn't really change.
// By subtracting the endPoint and beginPoint of the superview, we can see how much distance the point ACTUALLY traveled.
// the moveWith method does this for us.
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch *touch = [[event allTouches] anyObject];
    CGPoint endTouch = [touch locationInView:self.view.superview];
	endPoint=endTouch.y;
	[self moveWithBegin:beginPointSuper withEnd:endPoint];
}



- (void)viewDidLoad {
    [super viewDidLoad];
	CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/2);
    //NSLog(@"self.view.superview: %@", self.view.superview);
    [self.view.superview setTransform:transform];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Remove the listener so we don't get updates constantly. 
    
}

- (void)dealloc {
	
    // TODO add in all the other deallocs we need here.+
	[locationSlide release];
	[logoSlide release];
	
	[roomInstructions release];
	[loginInstructions release];
	
    [self.view release];
    [super dealloc];
}


@end