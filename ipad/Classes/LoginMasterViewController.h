//
//  LoginMasterViewController.h
//  Login
//
//  Created by Paula Jacobs on 6/29/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogoView.h"
#import "LocationViewController.h"
#import "RoomViewController.h"
#import "TinCanViewController.h"

@class LoginMasterViewController;
@class LocationViewController;
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
	NSString *chosenLocation;
	NSString *chosenRoom;
	
	// Text to appear on screen
	UILabel *loginInstructions;
	UILabel *roomInstructions;
	UILabel *locationInstructions;
	UILabel *locationSlide;
	UILabel *logoSlide;
	UIButton *loginButton;
	
	
	
	LocationViewController *locViewController;
	RoomViewController *roomViewController;
	TinCanViewController *controller;
}
- (id)initWithController:(TinCanViewController *)control;
-(void)moveWithBegin:(CGFloat)begin withEnd:(CGFloat)end;
-(void)infoButtonPressed:(id)sender;
-(void)chooseLocationWithLocation:(NSString *)loc;
-(void)chooseRoomWithRoom:(NSString *)room withMeeting:(NSString *)meeting withCount:(NSString*)counted;
@end
