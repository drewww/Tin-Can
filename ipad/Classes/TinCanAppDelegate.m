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


- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    
    // Write the current time to a preferences field. This will allow us to check, on startup, how long it's been
    // since we left. If it's a short amount of time, relogin with the old settings. Otherwise, force
    // a re-identification.
    CFPreferencesSetAppValue(CFSTR("LOGOUT_TIMESTAMP"), [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970], nil], kCFPreferencesCurrentApplication);
    CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication);
    NSLog(@"Wrote timestamp to preferences on terminate.");
}







- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
