//
//  TinCanAppDelegate.m
//  TinCan
//
//  Created by Drew Harry on 5/10/10.
//  Copyright MIT Media Lab 2010. All rights reserved.
//

#import "TinCanAppDelegate.h"
#import "ParticipantView.h"
#import "TinCanViewController.h"
#import "LoginMasterViewController.h"

@implementation TinCanAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	
    //TinCanViewController *tableViewController = [TinCanViewController alloc];
	viewController = [TinCanViewController alloc];
    	
//    [window setTransform:CGAffineTransformMakeRotation(M_PI/2)];
	[window setBackgroundColor:[UIColor clearColor]];
	
    [window addSubview:viewController.view];
	
    [window makeKeyAndVisible];
	
	return YES;
	
   // [window addSubview:viewController.view];
   // [window makeKeyAndVisible];
    
	//return YES;
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
