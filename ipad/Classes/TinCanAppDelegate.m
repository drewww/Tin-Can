//
//  TinCanAppDelegate.m
//  TinCan
//
//  Created by Drew Harry on 5/10/10.
//  Copyright MIT Media Lab 2010. All rights reserved.
//

#import "TinCanAppDelegate.h"
#import "TinCanViewController.h"
#import "LoginMasterViewController.h"
#import "UIApplication+ScreenMirroring.h"

@implementation TinCanAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	
   
	viewController = [TinCanViewController alloc];
    
    [application setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];

	[window setBackgroundColor:[UIColor clearColor]];
	
    [window addSubview:viewController.view];
	
    [window makeKeyAndVisible];
	
    
    // This works, but if you're actually plugged in, it represents a major performance hit. 
    // It doesn't SEEM to represent a performance problem if you're not plugged in at all,
    // so I'm going to just leave it here for now and see what happens.
    [[UIApplication sharedApplication] setupScreenMirroring];
    
	return YES;
	

}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
