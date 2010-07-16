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

@implementation TinCanViewController

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
    
    if(currentViewController == nil) {
        // Make the initial one and load it. For now, that's just the MeetingView.
        currentViewController = [[[MeetingViewController alloc] init] retain];
        
        // Make sure the viewcontroller has a reference back here, so it can send us 
        // messages if we need it.
        //currentViewController.parentViewController = self;
    }

    [self.view addSubview:currentViewController.view];
//    self.view = currentViewController.view;
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