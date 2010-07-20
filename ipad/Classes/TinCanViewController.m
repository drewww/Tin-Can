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
}

// Per advice here: http://stackoverflow.com/questions/2270835/best-practices-for-displaying-new-view-controllers-iphone
// This isn't beautiful, but since we have such a simple system I think it'll work.
// TODO figure out how to animate these transitions.

-(void) switchToViewController:(UIViewController *)c {
    if(c == currentViewController) return;
	c.view.alpha =0.0;
    [self.view addSubview:c.view];
	
	[UIView beginAnimations:@"move_to_assigned_participant" context:c];
    
    [UIView setAnimationDuration:1.0f];
    
    c.view.backgroundColor=[UIColor blackColor];
    c.view.alpha = 1.0;
    
	//    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/2);
    CGAffineTransform transform = c.view.transform;
    //transform = CGAffineTransformScale(transform, 0.4, 0.4);
    [self.view setTransform:transform];  
    
    // Now set the callback. 
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animateNewViewDidStop:finished:context:)];
    
    [UIView commitAnimations];
	

}

- (void) animateNewViewDidStop:(NSString *)animationId finished:(NSNumber *)finished context:(void *)context{
	 UIViewController *c = (UIViewController *)context;
	[currentViewController.view removeFromSuperview];
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