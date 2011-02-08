//
//  LoginMasterViewController.h
//  Login
//
//  Created by Paula Jacobs on 6/29/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogoView.h"
#import "UserViewController.h"
#import "RoomViewController.h"
#import "TinCanViewController.h"
#import "Location.h"
#import "Room.h"

// Do we need all of these? Should check sometime. 
@class LoginMasterViewController;
@class UserViewController;
@class RoomViewController;
@class LogoView;

@interface LoginMasterViewController : UIViewController {
	// Tracks the area of the view the user sees
	int currentPage;
	
	// These floats track the x coordinates of touches
	CGFloat beginPointSuper;
	CGFloat beginPoint;
	CGFloat endPoint;
	CGFloat currentPoint;
	
	// These track the user selections
	Room *chosenRoom;
	User *chosenUser;
	
	// Text to appear on screen
	UILabel *loginInstructions;
	UILabel *roomInstructions;
	UILabel *locationInstructions;
	UILabel *locationSlide;
	UILabel *logoSlide;
	UIButton *loginButton;
    
    UILabel *connectionInfoLabel;
    
	UserViewController *userViewController;
	RoomViewController *roomViewController;
	TinCanViewController *controller;
}


- (id) initWithController:(TinCanViewController *)control;

- (void) moveWithBegin:(CGFloat)begin withEnd:(CGFloat)end;

- (void) loginButtonPressed:(id)sender;

- (void) chooseRoom:(Room *)room;
- (void) chooseUser:(User *)user;

- (void) updateLoginButton;
- (void) setLoginButtonEnabled:(bool) enabled;




@end
