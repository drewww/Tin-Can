    //
//  AddTopicController.m
//  TinCan
//
//  Created by Drew Harry on 12/6/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "AddTopicController.h"


@implementation AddTopicController



- (id)init {
    self = [super init];
    
    if(self) {
        // more init
    }
    
    return self;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 110)];
    
    // Set up the text field.
    topicField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 280, 30)];
    
    topicField.borderStyle = UITextBorderStyleRoundedRect;
    topicField.textColor = [UIColor blackColor]; //text color
    topicField.font = [UIFont systemFontOfSize:18.0];  //font size
    topicField.placeholder = @"new topic";  //place holder
    topicField.backgroundColor = [UIColor whiteColor]; //background color
    topicField.autocorrectionType = UITextAutocorrectionTypeDefault;	// no auto correction support
    
    topicField.keyboardType = UIKeyboardTypeAlphabet;  // type of the keyboard
    topicField.returnKeyType = UIReturnKeyDone;  // type of the return key
    
    topicField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
    topicField.backgroundColor = [UIColor blackColor];
    
//    topicField.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed    
    
    submitButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    submitButton.frame = CGRectMake(300, 300, 280, 30);
    submitButton.center = CGPointMake(150, 70);
    submitButton.backgroundColor = [UIColor clearColor];
    [submitButton setTitle:@"Add Topic" forState: UIControlStateNormal];
    [submitButton setFont:[UIFont boldSystemFontOfSize:24.0f]];
    [submitButton addTarget:self action:@selector(addTopicButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
    [submitButton setEnabled: YES];
    
    submitButton.backgroundColor = [UIColor blackColor];
    
    
    [self.view addSubview:topicField];
    [self.view addSubview:submitButton];
    
    self.view.backgroundColor = [UIColor blackColor];
}


- (void) addTopicButtonPressed:(id) sender { 
    
    NSLog(@"Add button pressed! Contents: %@", topicField.text);

    // Figure out how to hide the popover here.
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
