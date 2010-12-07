//
//  AddTopicController.m
//  TinCan
//
//  Created by Drew Harry on 12/6/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "AddItemController.h"


@implementation AddItemController

@synthesize delegate;

- (id) initWithPlaceholder:(NSString *)placeholderString withButtonText:(NSString *)buttonLabelString{
    
    self = [super init];
    
    if(self) {
        // do init if necessary
        placeholder = placeholderString;
        buttonLabel = buttonLabelString;
    }
    
    return self;
}



// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 110)];
    
    // Set up the text field.
    textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 280, 30)];
    
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.textColor = [UIColor blackColor]; //text color
    textField.font = [UIFont systemFontOfSize:18.0];  //font size
    textField.placeholder = placeholder;  //place holder
    textField.backgroundColor = [UIColor whiteColor]; //background color
    textField.autocorrectionType = UITextAutocorrectionTypeDefault;	// no auto correction support
    
    textField.keyboardType = UIKeyboardTypeAlphabet;  // type of the keyboard
    textField.returnKeyType = UIReturnKeyDone;  // type of the return key
    
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
    textField.backgroundColor = [UIColor blackColor];
    
//    textField.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed    
    
    submitButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    submitButton.frame = CGRectMake(300, 300, 280, 30);
    submitButton.center = CGPointMake(150, 70);
    submitButton.backgroundColor = [UIColor clearColor];
    [submitButton setTitle:buttonLabel forState: UIControlStateNormal];
    [submitButton setFont:[UIFont boldSystemFontOfSize:24.0f]];
    [submitButton addTarget:self action:@selector(submitButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
    [submitButton setEnabled: YES];
    
    submitButton.backgroundColor = [UIColor blackColor];
    
    
    [self.view addSubview:textField];
    [self.view addSubview:submitButton];
    
    self.view.backgroundColor = [UIColor blackColor];
}


- (NSString *) getText {
    return textField.text;
}

- (void) submitButtonPressed:(id) sender { 
    
    NSLog(@"Add button pressed! Contents: %@", textField.text);

    if(delegate != nil) {
        [delegate itemSubmittedWithText:textField.text];
    }
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
