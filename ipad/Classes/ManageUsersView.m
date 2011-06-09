//
//  ManageUsersView.m
//  TinCan
//
//  Created by Drew Harry on 6/7/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "ManageUsersView.h"
#import "UIView+Rounded.h"
#import "ManageUsersTableViewController.h"

@implementation ManageUsersView

- (id) initWithLocation:(Location *)theLocation {

    UIView *baseUIView = [[[UIView alloc] initWithFrame:CGRectMake(-[self getBaseWidth], +15, [self getBaseWidth]*2, 600)] autorelease];
    
    manageUsersViewController = [[ManageUsersTableViewController alloc] init];
    manageUsersViewController.view.frame = CGRectMake(-[self getBaseWidth], +15, [self getBaseWidth]*2, 600);
    
    
    self = [super initWithFrame:CGRectMake(0, 0, [self getBaseWidth], [self getBaseHeight]) withDrawerView:manageUsersViewController.view];
    
    self.controller = nil;
    
    baseUIView.backgroundColor = [UIColor redColor];
    
    self.bounds = CGRectMake(-[self getBaseWidth]/2, -([self getBaseHeight] + 50)/2, [self getBaseWidth], [self getBaseHeight] + 50);
    
    
    renderView = [[[ManageUsersRenderView alloc] init] retain];
    [self addSubview:renderView];
    
    return self;
}


- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"Got a touch on the ManageUsersView!");
    
    [self setDrawerExtended:!drawerExtended];
    [manageUsersViewController extended];
    
    [controller userTaskDrawerExtended:self];
    
    
}

- (void) wasLaidOut {
    
    NSLog(@"in WAS LAID OUT for MANAGE USERS VIEW. side: %d", [self.side intValue]);
    
    [super wasLaidOut];
}

@end
