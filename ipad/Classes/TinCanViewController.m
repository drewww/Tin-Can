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
#import "ServerSelectViewController.h"
#import "tincan.h"

@class MeetingViewController;
@class LoginMasterViewController;
@implementation TinCanViewController

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
    
    if(currentViewController == nil) {

        // We have to decide what view to present here. There is some interesting flow at work:
        //      - try the IP we have stored. If it's reachable, then check and see if our login credentials are still good.
        //      - if the login credentials work, then do a get state with those go direct to the meetingviewcontroller. otherwise, present the login view
        
        CFStringRef lastServerRef = (CFStringRef)CFPreferencesCopyAppValue(CFSTR("SERVER"), kCFPreferencesCurrentApplication);
        NSString *serverAddr = nil;
        if(lastServerRef) {
            serverAddr = (NSString *)lastServerRef;
            CFRelease(lastServerRef);
        } 

        NSLog(@"serverAddr: %@", serverAddr);
        bool reachable = false;
        if(serverAddr != nil) {
            Reachability *serverReachability = [Reachability reachabilityWithHostName:serverAddr];
            NSLog(@"server reachability: %d", [serverReachability currentReachabilityStatus]);
            if([serverReachability currentReachabilityStatus] == NotReachable) {
                reachable = false;
            } else {
                
                // Make a blocking call to something on the server to see if it's awake.
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/status/", serverAddr, PORT, nil]];
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
                request.timeOutSeconds = 2;
                [request startSynchronous];
                NSError *error = [request error];
                NSLog(@"error: %@", error);
                if (!error) {
                    reachable = true;
                } else {
                    reachable = false;
                }
            }
        } 
                
        NSLog(@"Checking server reachability: %d for %@", reachable, serverAddr);
        if(reachable) {
            // present the meeting view controller.
            [ConnectionManager setServer:serverAddr];
            currentViewController = [[[LoginMasterViewController alloc] initWithController:self] retain];
            [self.view setTransform:CGAffineTransformMakeRotation(-M_PI)];
        } else {
            currentViewController = [[[ServerSelectViewController alloc] initWithController:self] retain];        
        }
    }

    [self.view addSubview:currentViewController.view];
    
}


// Per advice here: http://stackoverflow.com/questions/2270835/best-practices-for-displaying-new-view-controllers-iphone
// This isn't beautiful, but since we have such a simple system I think it'll work.

-(void) switchToViewController:(UIViewController *)c {
    NSLog(@"in switch to view controller, switching to controller: %@", c);
    
    
    if(c == currentViewController) return;
	c.view.alpha =0.0;
    [self.view addSubview:c.view];
	
	[UIView beginAnimations:@"fade_to_new_view_controller" context:c];
    
    [UIView setAnimationDuration:0.5f];
    
    c.view.backgroundColor=[UIColor blackColor];
    c.view.alpha = 1.0;
    
//    CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI/2);
    CGAffineTransform transform = c.view.transform;
    
    // Doing this extra rotation so that ipads in cases can sit up properly.
    // This just complicates all the rotational issues, but it's an okay for-now hack.
    transform = CGAffineTransformRotate(transform, -M_PI);
    [self.view setTransform:transform];  
    
    // Now set the callback. 
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animateNewViewDidStop:finished:context:)];
    
    [UIView commitAnimations];
}

- (void) animateNewViewDidStop:(NSString *)animationId finished:(NSNumber *)finished context:(void *)context{
	 UIViewController *c = (UIViewController *)context;
	[currentViewController.view removeFromSuperview];
    
    // Stop connection manager updates on this viewController.
    // This REALLY REALLY doesn't belong here. It should be in viewDidUnload or
    // dealloc, but the LoginMasterViewControler has 3 retains at this point usually,
    // and it's going to be a bit of a nightmare to track them all down. 
    [[ConnectionManager sharedInstance] removeListener:currentViewController];
    
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
    // (this feels wrong to me, not sure what's expected here)
    [currentViewController viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
    [currentViewController dealloc];
}


@end