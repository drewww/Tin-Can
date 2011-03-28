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

- (id)initWithTopic:(Topic *)theTopic
{
    self = [super init];
    if (self) {
        
        // We'll do some different things depending on the topic's status, eg
        // you can't delete a past topic only a future one.
        topic = theTopic;
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

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    // The details of this frame appear to not matter at all. It's set elsewhere. 
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.view.backgroundColor = [UIColor blackColor];
    
    startTopicButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    startTopicButton.frame = CGRectMake(5, 5, 90, 40);
    startTopicButton.backgroundColor = [UIColor clearColor];
    [startTopicButton setTitle:@"Start" forState:UIControlStateNormal];
    [startTopicButton.titleLabel setFont:[UIFont boldSystemFontOfSize:24.0f]];
    [startTopicButton addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    startTopicButton.enabled = YES;
        
    stopTopicButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    stopTopicButton.frame = CGRectMake(100, 5, 70, 40);
    stopTopicButton.backgroundColor = [UIColor clearColor];
    [stopTopicButton setTitle:@"Stop" forState:UIControlStateNormal];
    [stopTopicButton.titleLabel setFont:[UIFont boldSystemFontOfSize:24.0f]];
    [stopTopicButton addTarget:self action:@selector(stopButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    stopTopicButton.enabled = YES;
    
    deleteTopicButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    deleteTopicButton.frame = CGRectMake(175, 5, 90, 40);
    deleteTopicButton.backgroundColor = [UIColor clearColor];
    [deleteTopicButton setTitle:@"Delete" forState:UIControlStateNormal];
    [deleteTopicButton.titleLabel setFont:[UIFont boldSystemFontOfSize:24.0f]];
    [deleteTopicButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    deleteTopicButton.enabled = NO;
    
    [self.view addSubview:startTopicButton];
    [self.view addSubview:stopTopicButton];
    [self.view addSubview:deleteTopicButton];    
}

- (void) updateButtonStates {
    // I'm not sure if I can do this logic here or not - is this called each time the popover is created?
    switch(topic.status) {
        case kCURRENT:
            [startTopicButton setTitle:@"Start" forState:UIControlStateNormal];
            startTopicButton.enabled = NO;
            stopTopicButton.enabled = YES;
            deleteTopicButton.enabled = NO;
            break;
        case kFUTURE:
            [startTopicButton setTitle:@"Start" forState:UIControlStateNormal];
            startTopicButton.enabled = YES;
            stopTopicButton.enabled = NO;
            deleteTopicButton.enabled = YES;
            break;
        case kPAST:
            [startTopicButton setTitle:@"Restart" forState:UIControlStateNormal];
            startTopicButton.enabled = YES;
            stopTopicButton.enabled = NO;
            deleteTopicButton.enabled = NO;
            break;
    }
    
    [self manageButtonAlpha];
}

- (void) manageButtonAlpha {
    for (UIButton *button in [NSArray arrayWithObjects:startTopicButton, stopTopicButton, deleteTopicButton, nil]) {
        
        if(button.enabled) {
            button.alpha = 1.0;
        } else {
            button.alpha = 0.6;
        }

    }
}


- (void) startButtonPressed:(id)sender {
    [self.delegate startTopic];
}

- (void) stopButtonPressed:(id)sender {
    [self.delegate stopTopic];
}

- (void) deleteButtonPressed:(id)sender {
    [self.delegate deleteTopic];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [startTopicButton release];
    [stopTopicButton release];
    [deleteTopicButton release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
