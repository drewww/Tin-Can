//
//  SettingsAppDelegate.m
//  Settings
//
//  Created by Paula Jacobs on 7/14/10.
//  Copyright MIT Media Lab 2010. All rights reserved.
//

#import "SettingsAppDelegate.h"


#import "RootViewController.h"
#import "DetailViewController.h"


@implementation SettingsAppDelegate

@synthesize window, splitViewController, rootViewController, detailViewController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    
    // Add the split view controller's view to the window and display.
    [window addSubview:splitViewController.view];
    [window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [splitViewController release];
    [window release];
    [super dealloc];
}


@end

