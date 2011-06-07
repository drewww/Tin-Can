//
//  ExtendableDrawerView.h
//  
//
//  Created by Drew Harry on 6/7/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskContainerView.h"

@interface ExtendableDrawerView : UIView {
    UIViewController *controller;
    
    TaskContainerView *taskContainerView;
    
    bool taskDrawerExtended;
    bool userExtended;
    
    CGRect initialBounds;
    CGRect initialFrame;
    
    CGRect taskContainerViewInitialFrame;
    
    float drawerExtendAmount;

    NSNumber *side;
}

- (void) setDrawerExtended:(bool)extended;

- (void) wasLaidOut;


// These are basically constants, but making them functions
// so they can be overridden conveniently by subclasses if they so 
// desire.
- (int) getUserExtendHeight;
- (int) getContainerEdgeOffset;
- (int) getBaseHeight;
- (int) getBaseWidth;

@property (nonatomic, retain) NSNumber *side;
@property (nonatomic, retain) UIViewController *controller;

@end
