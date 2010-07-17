//
//  TinCanViewController.m
//  TinCan
//
//  Created by Drew Harry on 7/12/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "TinCanViewController.h"
#import "MeetingViewController.h"
#import "LoginMasterViewController.h"
#import "ConnectionManager.h"
#import "Location.h"
#import "StateManager.h"


@class LoginMasterViewController;
@implementation TinCanViewController

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
    
    if(currentViewController == nil) {
        // Make the initial one and load it. For now, that's just the MeetingView.
        currentViewController = [[[LoginMasterViewController alloc] initWithController:self] retain];
        
        // Make sure the viewcontroller has a reference back here, so it can send us 
        // messages if we need it.
        //currentViewController.parentViewController = self;
    }

    [self.view addSubview:currentViewController.view];
//    self.view = currentViewController.view;

    
    
    // Gonna do some StateManager testing here. This is NOT WHERE IT WILL GO LATER,
    // I just need a place to execute some code. I won't check this code in without
    // commenting it out first, so if you're looking at this and it's uncommented and
    // causing problems, just comment it out.
    
//    ConnectionManager *conMan = [ConnectionManager sharedInstance];
//    [conMan getState];
    
    
    // pick a random location
//    Location *myLocation = [[[StateManager sharedInstance] getLocations] anyObject];
//    NSLog(@"picking location arbitarily: %@", myLocation);
//    [conMan setLocation:myLocation.uuid];
//    [conMan connect];
    
    
}

// Per advice here: http://stackoverflow.com/questions/2270835/best-practices-for-displaying-new-view-controllers-iphone
// This isn't beautiful, but since we have such a simple system I think it'll work.
// TODO figure out how to animate these transitions.

-(void) switchToViewController:(UIViewController *)c {
    if(c == currentViewController) return;

    [currentViewController.view removeFromSuperview];
    [self.view addSubview:c.view];
    [currentViewController release];
    currentViewController = [c retain];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return NO;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Pass the message down to the current view.
    [currentViewController viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
    [currentViewController dealloc];
}


@end