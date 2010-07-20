    //
//  LoginMasterViewController.m
//  Login
//
//  Created by Paula Jacobs on 6/29/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "LoginMasterViewController.h"
#import "LoginAppDelegate.h"
#import "LogoView.h"
#import "LocationViewController.h"
#import "RoomViewController.h"
#import "headerView.h"
#import "TinCanViewController.h"
#import "MeetingViewController.h"
@class TinCanViewController;

@implementation LoginMasterViewController
- (id)initWithController:(TinCanViewController *)control{
	if ((self = [super init])) {

	controller=control;
	NSLog(@"is being called with %@:", controller);
	} 
	return self;
		
}
- (void)loadView {
	
	NSLog(@"View is being called");
	// Initializers
	// Sets the frame and then sets the center of the view to be at the location our our Logo.
	// The currentPage variable tracks which part of the view the user is seeing
	self.view= [[UIView alloc] initWithFrame:CGRectMake(0,0, 700.0, 2000.0) ];
	self.view.center= CGPointMake(768/2.0, 1024/2.0+600);
	[self.view setBackgroundColor:[UIColor blackColor]]; 
	currentPage=0;
	
	
	// Tracks user selections
	chosenRoom=NULL;
	chosenLocation=NULL;
	
	
	// Dimentions
	
	
	
	
	// Elements in the Login page (Our Logo, Our Location Table and Our Room Table)
	LogoView *picView= [[[LogoView alloc] initWithImage:[UIImage imageNamed:@"tin_can_phone.jpg"] 
											  withFrame: CGRectMake(self.view.frame.size.width/2.0-250, 100, 500, 500) ] retain];
	
	locViewController = [[[LocationViewController alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-200,self.view.frame.size.height/2.0-250, 300,600) withController:self] retain];
	
	roomViewController = [[[RoomViewController alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-200,self.view.frame.size.height/2.0-250+600, 300,600) withController:self] retain];
	
	
	// Arrows
	LogoView *arrowView= [[[LogoView alloc] initWithImage:[UIImage imageNamed:@"rightarrow.png"] 
												withFrame: CGRectMake(self.view.frame.size.width/2.0-25,625, 50,100) ] retain];
	LogoView *arrowView2= [[[LogoView alloc] initWithImage:[UIImage imageNamed:@"rightarrow.png"] 
												 withFrame: CGRectMake(self.view.frame.size.width/2.0-25,625+600, 50,100) ] retain];
	
	
	// Initializes Login Button
	loginButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	[loginButton setTransform:CGAffineTransformMakeRotation(M_PI/2)];
	loginButton.frame = CGRectMake(self.view.frame.size.width/2.0-200+100,self.view.frame.size.height/2.0-250+600+475, 100,150);
	loginButton.backgroundColor = [UIColor clearColor];
	[loginButton setTitle:@"Login" forState: UIControlStateNormal];
	[loginButton setFont:[UIFont boldSystemFontOfSize:30.0f]];
	[loginButton addTarget:self action:@selector(infoButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
	[loginButton setEnabled: NO];
	
	// Disabled Settings for Login Button
	
	[loginButton setBackgroundImage:[UIImage imageNamed:@"greyButton-1.png"] forState:UIControlStateDisabled];
	loginButton.adjustsImageWhenDisabled = YES;
	if( loginButton.enabled==NO){
		
	// sets user intructions for login
		loginInstructions = [[UILabel alloc]
							 initWithFrame:CGRectMake(self.view.frame.size.width/2.0-200-100,self.view.frame.size.height/2.0-250+600+250, 300,600)];
		[loginInstructions setTransform:CGAffineTransformMakeRotation(M_PI/2)];
		loginInstructions.text = @"Have not chosen \n a Location \nAND\n a Room";
		loginInstructions.numberOfLines = 0;
		loginInstructions.textAlignment = UITextAlignmentCenter;
		loginInstructions.textColor = [UIColor redColor];
		loginInstructions.backgroundColor = [UIColor clearColor];
		loginInstructions.font = [UIFont boldSystemFontOfSize:20.0f];
		[self.view addSubview:loginInstructions];
		
	}
	
	
	// Headers
	//HeaderView *headerLocation =[[[HeaderView alloc] 
	//							  initWithFrame:CGRectMake() withTitle:@"Locations"] retain];
//	HeaderView *headerRoom =[[[HeaderView alloc] 
	//						  initWithFrame:CGRectMake() withTitle:@"Rooms"] retain];
	
	
	
	// Borders
	//UIView *locationBorder = [[UIView alloc] initWithFrame:CGRectMake()];
	//[locationBorder setBackgroundColor:[UIColor grayColor]];
	
	//UIView *roomBorder = [[UIView alloc] initWithFrame:
	//					  CGRectMake()];
	//[roomBorder setBackgroundColor:[UIColor grayColor]];
	
	
	// Instruction text
	logoSlide = [[UILabel alloc] 
				 initWithFrame:CGRectMake(-50,325, 200,50)];
	logoSlide.text = @"Slide";
	logoSlide.numberOfLines = 0;
	logoSlide.textAlignment = UITextAlignmentCenter;
	logoSlide.textColor = [UIColor whiteColor];
	logoSlide.backgroundColor = [UIColor clearColor];
	logoSlide.font = [UIFont systemFontOfSize:50.0f];
	[logoSlide setTransform:CGAffineTransformMakeRotation(M_PI/2)];
	
	locationSlide = [[UILabel alloc] 
					 initWithFrame:CGRectMake(-50,self.view.frame.size.height/2.0-25,200,50)];
	locationSlide.text = @"Slide";
	locationSlide.numberOfLines = 0;
	locationSlide.textAlignment = UITextAlignmentCenter;
	locationSlide.textColor = [UIColor whiteColor];
	locationSlide.backgroundColor = [UIColor clearColor];
	locationSlide.font = [UIFont systemFontOfSize:50.0f];
	[locationSlide setTransform:CGAffineTransformMakeRotation(M_PI/2)];
	
//	locationInstructions = [[UILabel alloc] initWithFrame:CGRectMake()];
//	locationInstructions.numberOfLines = 0;
//	locationInstructions.text = @"Choose your physical location";
//	locationInstructions.textAlignment = UITextAlignmentCenter;
//	locationInstructions.textColor = [UIColor whiteColor];
//	locationInstructions.backgroundColor = [UIColor blackColor];
//	locationInstructions.font = [UIFont boldSystemFontOfSize:20.0f];
//	
//	roomInstructions = [[UILabel alloc] initWithFrame:CGRectMake()];
//	roomInstructions.numberOfLines = 0;
//	roomInstructions.text = @"Choose a virtual room";
//	roomInstructions.textAlignment = UITextAlignmentCenter;
//	roomInstructions.textColor = [UIColor whiteColor];
//	roomInstructions.backgroundColor = [UIColor blackColor];
//	roomInstructions.font = [UIFont boldSystemFontOfSize:20.0f];
	
	
	// Add Elements to View
	[self.view addSubview:picView];
	[self.view addSubview:loginButton];
	[self.view addSubview:arrowView];
	[self.view addSubview:arrowView2];
	[self.view addSubview:roomInstructions];
	[self.view addSubview:locationInstructions];
	[self.view addSubview:locationSlide];
	[self.view addSubview:logoSlide];
	//[self.view addSubview:roomBorder];
	//[self.view addSubview:locationBorder];
	[self.view addSubview:locViewController.view];
	[self.view addSubview:roomViewController.view];
	//[self.view addSubview:headerLocation];
	//[self.view addSubview:headerRoom];
	[self.view setNeedsDisplay];
	
	
	}


// Dictates what action to take when a User makes a selection
-(void)infoButtonPressed:(id)sender{
	
	NSLog(@"I have been pressed");
	[controller switchToViewController:[[[MeetingViewController alloc] init] retain]];
}



// Stores the location the User seleted in chosenLocation then updates login instructions
-(void)chooseLocationWithLocation:(NSString *)loc{
	
	chosenLocation= loc;
	 //Updates our Login Button and Login intstructions to match the Users selections
	if(chosenRoom!=NULL){
		[loginButton setEnabled: YES];
		loginInstructions.text = @" ";
	}
	else{
		loginInstructions.text = @"Have not choosen \n a Room";
	}
	
}		


// Stores the room the user seleted in chosenRoom then updates login instructions
-(void)chooseRoomWithRoom:(NSString *)room withMeeting:(NSString *)meeting withCount:(NSString*)counted{
	
	chosenRoom= room;
	//Updates our Login Button and Login Intstuctions to match the Users selections
	if(chosenLocation!=NULL){
		[loginButton setEnabled: YES];
		loginInstructions.text = @" ";
	}
	else{
		loginInstructions.text = @"Have not chosen \n a Location";
	}
	
}	


// Decides what movement to take based on our current location (currentPage) and the size and direction of our stroke (begin-end)
// Then updates the view and the currentPage variable to match those movements
-(void)moveWithBegin:(CGFloat)begin withEnd:(CGFloat)end{
	
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
		else{
			self.view.center=CGPointMake(768/2.0,1024/2.0-600);
			currentPage=2;
		}
		
	}

	[self.view setNeedsDisplay];	
	[UIView setAnimationDelegate:self.view];
	[UIView commitAnimations];
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
	if((self.view.center.y+(currentPoint-beginPoint)<1601) && (self.view.center.y+(currentPoint-beginPoint)>-800)){
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
    NSLog(@"self.view.superview: %@", self.view.superview);
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
}

- (void)dealloc {
	
	[locationSlide release];
	[logoSlide release];
	
	[roomInstructions release];
	[loginInstructions release];
	
    [self.view release];
    [super dealloc];
}


@end
