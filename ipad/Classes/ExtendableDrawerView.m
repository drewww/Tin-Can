//
//  ExtendableDrawerView.m
//  
//
//  Created by Drew Harry on 6/7/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "ExtendableDrawerView.h"


@implementation ExtendableDrawerView

@synthesize side;
@synthesize controller;

#define TOP 0
#define RIGHT 1
#define BOTTOM 2
#define LEFT 3


- (id) initWithFrame:(CGRect)frame withDrawerView:(UIView *)theDrawerView {
    self = [super initWithFrame:frame];
    
    self.controller = nil;
    
    drawerExtended = FALSE;

    //the + 11 was to hide the container view well under the user
    drawerView = [theDrawerView retain];
    [self addSubview:drawerView];

    
    [self sendSubviewToBack:drawerView];
    
    drawerView.alpha = 0;
	[UIView beginAnimations:@"fade_in" context:drawerView];
	
	[UIView setAnimationDuration:.5f];
	
	drawerView.alpha = 1.0;
	
	
	[UIView commitAnimations];
    self.alpha = 0;
	[UIView beginAnimations:@"fade_in" context:self];
	
	[UIView setAnimationDuration:.3f];
	
	self.alpha = 1.0;
	
	
	[UIView commitAnimations];
	
    [self setNeedsDisplay];
    
    return self;
}

- (void) setDrawerExtended:(bool)extended {
    if(extended != drawerExtended) {
        // If this is a change in the current state, trigger an animation
        // to update the situation.
        
        // This is implied by the previous if, but making it
        // explicit for readability.
        if(drawerExtended == false && extended==true) {
            [UIView beginAnimations:@"extend_drawer" context:nil];
            
            // Extend by the current height of the task drawer.
            
            [UIView setAnimationDuration:0.4f];
            
            float frameDX;
            float frameDY;
            
            float yExtendAmount;
            float xExtendAmount;
            
            float xOffsetAmount;
            
            switch([self.side intValue]) {
                case 0:
                case 2:
                    yExtendAmount =  drawerView.bounds.size.height + [self getUserExtendHeight] + 50;
                    xExtendAmount =  drawerView.bounds.size.width - self.bounds.size.width;
                    
                    xOffsetAmount = ABS(drawerView.frame.origin.x - self.bounds.origin.x);
                    
                    drawerExtendAmount = yExtendAmount;
                    
                    drawerView.center = CGPointMake(drawerView.center.x, drawerView.center.y - yExtendAmount);
                    break;
                case 1:
                case 3:
                    yExtendAmount =  drawerView.bounds.size.width + [self getUserExtendHeight] + 50;
                    xExtendAmount =  drawerView.bounds.size.height - self.bounds.size.width;
                    
                    xOffsetAmount = ABS(drawerView.frame.origin.x - self.bounds.origin.x);
                    
                    drawerExtendAmount = yExtendAmount;
                    
                    
                    drawerView.center = CGPointMake(drawerView.center.x, drawerView.center.y - yExtendAmount);
                    break;
                    
            }
            
            frameDX = 0;
            frameDY = 0;
            
            switch ([self.side intValue]) {
                case 0:
                    frameDX = yExtendAmount/2;
                    frameDY = xExtendAmount/2 - xOffsetAmount;
                    break;
                case 1:
                    frameDY = yExtendAmount/2;
                    frameDX = -xExtendAmount/2 + xOffsetAmount;
                    break;
                case 2:
                    frameDX = -yExtendAmount/2;
                    frameDY = -xExtendAmount/2 + xOffsetAmount;
                    break;
                case 3:
                    frameDY = -yExtendAmount/2;
                    frameDX = xExtendAmount/2 - xOffsetAmount;
                    break;
            }
            
            CGRect curBounds = self.bounds;
            initialBounds = self.bounds;
            
            // Adjust the bounds size and origin to make it big enough for
            // the task drawer and in the right place relative to drawing
            // origin.
            curBounds.size.height = curBounds.size.height + yExtendAmount;
            curBounds.origin.y = curBounds.origin.y - yExtendAmount;
            
            curBounds.size.width = curBounds.size.width + xExtendAmount;
            curBounds.origin.x = curBounds.origin.x - xOffsetAmount;
            
            self.bounds = curBounds;
            
            // Move the frame appropriately to compensate for the change in bounds size.
            CGRect curFrame = self.frame;            
            initialFrame = self.frame;
            
            curFrame.origin.y = curFrame.origin.y - frameDY;
            curFrame.origin.x = curFrame.origin.x - frameDX;
            
            self.frame = curFrame;
            
            NSLog(@"finalBounds: %@", NSStringFromCGRect(self.bounds));
            
            
            [UIView commitAnimations];
            drawerExtended = true;
            
            // Update the bounds of the UserView to include the task box.
            
            // Show the backdrop from the controller so 
            [controller setBackdropHidden:FALSE];
            
        } else {
            // in this situation, we can be sure that
            // taskDrawerExtended == true && extended == false
            [UIView beginAnimations:@"retract_drawer" context:nil];
            
            [UIView setAnimationDuration:0.4f];
            
            // We save this when we're laid out and the task container view
            // is put in its proper position. 
            drawerView.frame = taskContainerViewInitialFrame;
            
            self.frame = initialFrame;
            self.bounds = initialBounds;
            
            
            [UIView commitAnimations];        
            drawerExtended = false;
            
            [controller setBackdropHidden:TRUE];
        }
    }
}


- (void) wasLaidOut {
    
    // Now, move the TaskContainer around based on what side we're on (eg what our orientation is).
    
    // First step, just make sure the rotations are right; everything facing up.
    float newRot;
    switch([self.side intValue]) {
        case 0:
            newRot = M_PI;
            break;
        case 1:
            newRot = M_PI/2;
            break;
        case 2:
            newRot = 0;
            break;
        case 3:
            newRot = -M_PI/2;
            break;
    }
    drawerView.transform = CGAffineTransformMakeRotation(newRot);
    
    CGRect globalBounds;
    float distanceFromTop;
    float distanceFromBottom;
    float distanceFromLeft;
    float distanceFromRight;
    
    bool adjustLeftRight = false;
    bool adjustTopBottom = false;
    
    CGRect initialDrawerFrame;
    
    int adjustDirection;
    
    
    switch([self.side intValue]) {
        case 0:
            initialDrawerFrame = CGRectMake(-[self getBaseWidth], 15, [self getBaseWidth]*2, 600);
            adjustLeftRight = true;
            adjustDirection = 1;
            break;
            
        case 2:
            initialDrawerFrame = CGRectMake(-[self getBaseWidth], 15, [self getBaseWidth]*2, 600);
            adjustLeftRight = true;
            adjustDirection = -1;
            break;
            
        case 1:
            initialDrawerFrame = CGRectMake(-[self getBaseWidth], 15, 600, [self getBaseWidth]*2);
            adjustTopBottom = true;
            adjustDirection = -1;
            break;
            
        case 3:
            initialDrawerFrame = CGRectMake(-[self getBaseWidth], 15, 600, [self getBaseWidth]*2);
            adjustTopBottom = true;
            adjustDirection = 1;
            break;
    }
    
    drawerView.frame = initialDrawerFrame;
    globalBounds = [self convertRect:drawerView.frame toView:self.superview];
    
    
    distanceFromLeft = CGRectGetMinY(globalBounds) - [self getContainerEdgeOffset];
    distanceFromRight = CGRectGetMaxY(globalBounds) - 1024 + [self getContainerEdgeOffset ];
    distanceFromTop = CGRectGetMaxX(globalBounds) - 768 + [self getContainerEdgeOffset];
    distanceFromBottom = CGRectGetMinX(globalBounds) - [self getContainerEdgeOffset];
    
    float adjustment = 0.0;
    if(adjustLeftRight && distanceFromLeft < 0) {
        adjustment = distanceFromLeft * adjustDirection;
    } else if (adjustLeftRight && distanceFromRight > 0) {
        adjustment = distanceFromRight * adjustDirection;
    }
    
    if(adjustTopBottom && distanceFromTop > 0) {
        adjustment = distanceFromTop * adjustDirection;
    } else if (adjustTopBottom && distanceFromBottom < 0) {
        adjustment = distanceFromBottom * adjustDirection;
    }
    
    drawerView.frame = CGRectMake(drawerView.frame.origin.x + adjustment,
                                         drawerView.frame.origin.y,
                                         drawerView.frame.size.width,
                                         drawerView.frame.size.height);
    
    globalBounds = [self convertRect:drawerView.frame toView:self.superview];
    
    taskContainerViewInitialFrame = drawerView.frame;
}


- (int)getUserExtendHeight {
    return 20;
}

- (int)getContainerEdgeOffset {
    return 40;
}

- (int)getBaseHeight {
    return 90;
}

- (int)getBaseWidth {
    return 180;
}

- (void)dealloc {    
    [drawerView release];
    [super dealloc];
}



@end
