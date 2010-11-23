//
//  ServerSelectViewController.m
//  TinCan
//
//  Created by Drew Harry on 11/19/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "ServerSelectViewController.h"


@implementation ServerSelectViewController


- (id) initWithController:(TinCanViewController *)theController {
    
    if((self = [super init])) {
        
        controller = theController;
        
        servers = [[NSArray arrayWithObjects:@"localhost", @"18.85.35.212", nil] retain];
    }
    
    return self;
}

- (void) loadView {
    
    NSLog(@"loading view!");
    
    self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.center = CGPointMake(384, 512);
    
    self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
    
    
    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 200, 30)];
    testView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:testView];
    
    
    UIButton *connectButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    //[connectButton setTransform:CGAffineTransformMakeRotation(M_PI/2)];
    connectButton.frame = CGRectMake(100, 100, 200, 30);
    connectButton.backgroundColor = [UIColor clearColor];
    [connectButton setTitle:@"Connect" forState: UIControlStateNormal];
    [connectButton setFont:[UIFont boldSystemFontOfSize:30.0f]];
    [connectButton addTarget:self action:@selector(connectButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
    [connectButton setEnabled: NO];
    
    UITextField *ipField = [[UITextField alloc] initWithFrame:CGRectMake(300, 300, 300, 50)];
    ipField.borderStyle = UITextBorderStyleRoundedRect;
    ipField.textColor = [UIColor blackColor]; //text color
    ipField.font = [UIFont systemFontOfSize:24.0];  //font size
    ipField.placeholder = @"server address";  //place holder
    ipField.backgroundColor = [UIColor whiteColor]; //background color
    ipField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
    
    ipField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;  // type of the keyboard
    ipField.returnKeyType = UIReturnKeyDone;  // type of the return key
    
    ipField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
    
    ipField.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed    
    
    [self.view addSubview:connectButton];
    [self.view bringSubviewToFront:connectButton];
    
    [self.view addSubview:ipField];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}


- (void) connectButtonPressed:(id) sender {
 
    NSLog(@"CONNECT BUTTON PRESSED!");
}

- (void) viewDidLoad {

    
}


#pragma mark UITextFieldDelegate Protocol

- (void) textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"Editing completed!");
}

@end
