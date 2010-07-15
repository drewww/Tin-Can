//
//  LoginAppDelegate.m
//  Login
//
//  Created by Drew Harry on 6/18/10.
//  Copyright MIT Media Lab 2010. All rights reserved.
//

#import "LoginAppDelegate.h"
#import "LoginMasterViewController.h"




@implementation LoginAppDelegate

@synthesize window;
@synthesize viewController;


//Rotates Window, paints it black and adds our viewController to it
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    LoginMasterViewController *tableViewController = [LoginMasterViewController alloc];
	
	CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/2);
	
	[window setTransform:transform];
	
	[window setBackgroundColor:[UIColor blackColor]];
	
    [window addSubview:tableViewController.view];
	
    [window makeKeyAndVisible];
	
	return YES;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
