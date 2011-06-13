//
//  ManageUsersView.h
//  TinCan
//
//  Created by Drew Harry on 6/7/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ExtendableDrawerView.h"
#import "ManageUsersRenderView.h"
#import "ManageUsersTableViewController.h"
#import "ManageUsersView.h"

@interface ManageUsersContainerView : UIView {
    ManageUsersRenderView *renderView;
    
    UIViewController *controller;
    
    NSNumber *side;
    
    CGPoint retractedCenter;
}

- (id) init;

@property (nonatomic, retain) UIViewController *controller;
@property (nonatomic, retain) NSNumber *side;

@end
