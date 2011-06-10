//
//  ManageUsersView.m
//  TinCan
//
//  Created by Drew Harry on 6/7/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "ManageUsersContainerView.h"
#import "UIView+Rounded.h"
#import "ManageUsersTableViewController.h"

#define BASE_HEIGHT 90
#define BASE_WIDTH 180

@implementation ManageUsersContainerView

@synthesize extended;
@synthesize controller;
@synthesize side;

- (id) initWithLocation:(Location *)theLocation {

//    UIView *baseUIView = [[[UIView alloc] initWithFrame:CGRectMake(-BASE_WIDTH, +15, BASE_WIDTH*2, 600)] autorelease];
    
//    mainView = [[ManageUsersView alloc] init];
//    mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 600, 400)];
//    mainView.backgroundColor = [UIColor greenColor];
//    mainView.center = CGPointMake(384, 512);
//
//    ManageUsersView *manageUsers = [[ManageUsersView alloc] init];
//    manageUsers.center = CGPointMake(384, 512);
//    [self.superview addSubview:manageUsers];
//    [self.superview bringSubviewToFront:manageUsers];

    
    self = [super initWithFrame:CGRectMake(0, 0, BASE_WIDTH, BASE_HEIGHT)];
    
//    [self.superview addSubview:mainView];
//    [self.superview bringSubviewToFront:mainView];
    
    self.controller = nil;
        
    self.bounds = CGRectMake(-BASE_WIDTH/2, -(BASE_HEIGHT + 50)/2, BASE_WIDTH, BASE_HEIGHT + 50);
    
    
    renderView = [[[ManageUsersRenderView alloc] init] retain];
    [self addSubview:renderView];
    
    extended = false;
    
    return self;
}


- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"Got a touch on the ManageUsersView!");

    [controller toggleManageUsers];
}

//- (void) wasLaidOut {
//    
//    float newRot;
//    switch([self.side intValue]) {
//        case 0:
//            newRot = M_PI;
//            break;
//        case 1:
//            newRot = M_PI/2;
//            break;
//        case 2:
//            newRot = 0;
//            break;
//        case 3:
//            newRot = -M_PI/2;
//            break;
//    }
//    mainView.transform = CGAffineTransformMakeRotation(newRot);
//    
//    
//    // We're going to need to do side-specific layout here, but for a first pass we can just
//    // hard code it.
//    retractedCenter = [self.superview convertPoint:CGPointMake(768/2, 1024 + 1024/2) toView:self];
//    mainView.center = retractedCenter;
//    
//    
//    NSLog(@"in WAS LAID OUT for MANAGE USERS VIEW. side: %d", [self.side intValue]);
//    
//}

@end
