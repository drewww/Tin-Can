//
//  ManageTopicController.m
//  TinCan
//
//  Created by Drew Harry on 3/28/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "ManageTopicController.h"


@implementation ManageTopicController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    // The details of this frame appear to not matter at all. It's set elsewhere. 
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
                 
    startTopicButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    startTopicButton.frame = CGRectMake(5, 5, 75, 30);
    startTopicButton.backgroundColor = [UIColor clearColor];
    [startTopicButton setTitle:@"Start" forState:UIControlStateNormal];
    [startTopicButton setFont:[UIFont boldSystemFontOfSize:24.0f]];
    [startTopicButton addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    startTopicButton.enabled = YES;

    [self.view addSubview:startTopicButton];
}


- (void) startButtonPressed {
    [self.delegate startTopic];
}

- (void) stopButtonPressed {
    [self.delegate stopTopic];
}

- (void) deleteButtonPressed {
    [self.delegate deleteTopic];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
