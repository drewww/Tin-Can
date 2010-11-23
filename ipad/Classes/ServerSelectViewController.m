//
//  ServerSelectViewController.m
//  TinCan
//
//  Created by Drew Harry on 11/19/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "ServerSelectViewController.h"
#import "ConnectionManager.h"
#import "LoginMasterViewController.h"

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
    
    UIButton *connectButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
    //[connectButton setTransform:CGAffineTransformMakeRotation(M_PI/2)];
    connectButton.frame = CGRectMake(300, 300, 200, 40);
    connectButton.center = CGPointMake(512, 380);
    connectButton.backgroundColor = [UIColor clearColor];
    [connectButton setTitle:@"Connect" forState: UIControlStateNormal];
    [connectButton setFont:[UIFont boldSystemFontOfSize:30.0f]];
    [connectButton addTarget:self action:@selector(connectButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
    [connectButton setEnabled: YES];
    
    serverField = [[UITextField alloc] initWithFrame:CGRectMake(300, 300, 400, 50)];
    serverField.center = CGPointMake(512, 330);
    serverField.borderStyle = UITextBorderStyleRoundedRect;
    serverField.textColor = [UIColor blackColor]; //text color
    serverField.font = [UIFont systemFontOfSize:30.0];  //font size
    serverField.placeholder = @"server address";  //place holder
    serverField.backgroundColor = [UIColor whiteColor]; //background color
    serverField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
    
    serverField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;  // type of the keyboard
    serverField.returnKeyType = UIReturnKeyDone;  // type of the return key
    
    serverField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
    
    serverField.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed    
    
    [self.view addSubview:connectButton];
    [self.view bringSubviewToFront:connectButton];
    
    [self.view addSubview:serverField];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}


- (void) connectButtonPressed:(id) sender {
    [ConnectionManager setServer:serverField.text];
    NSLog(@"Setting the server to %@", serverField.text);
    
    // Now transition to a new view.
   UIViewController *nextViewController = [[[LoginMasterViewController alloc] initWithController:controller] retain];
   
   [controller switchToViewController:nextViewController];
}

- (void) viewDidLoad {

    
}


#pragma mark UITextFieldDelegate Protocol

- (void) textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"Editing completed!");
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Should return");
    
    [textField resignFirstResponder];
    return true;
}

@end
