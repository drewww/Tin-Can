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

#define BASE_HEIGHT 70
#define BASE_WIDTH 90

@implementation ManageUsersContainerView

@synthesize controller;
@synthesize side;

- (id) init {
    
    self = [super initWithFrame:CGRectMake(0, 0, BASE_WIDTH, BASE_HEIGHT)];
        
    self.controller = nil;
        
    self.bounds = CGRectMake(-BASE_WIDTH/2, -(BASE_HEIGHT + 50)/2, BASE_WIDTH, BASE_HEIGHT + 50);
    
    renderView = [[[ManageUsersRenderView alloc] init] retain];
    [self addSubview:renderView];
        
    return self;
}


- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"Got a touch on the ManageUsersView!");

    [controller toggleManageUsers];
}

- (void) setNeedsDisplay {
    [super setNeedsDisplay];
    
    [renderView setNeedsDisplay];
}

@end
