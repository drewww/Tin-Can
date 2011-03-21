//
//  UserView.m
//  TinCan
//
//  Created by Drew Harry on 8/5/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "UserView.h"
#import "UIColor+Util.h"
#import "StateManager.h"


@implementation UserView

// This class is a shell - most of the real heavy lifting happens in the UserRenderView. See
// that class for a discussion about why there are two classes for user drawing.

#define TOP 0
#define RIGHT 1
#define BOTTOM 2
#define LEFT 3

#define USER_EXTEND_HEIGHT 20

#define CONTAINER_EDGE_OFFSET 40

@synthesize side;
@synthesize controller;

- (id) initWithUser:(User *)theUser {

    self = [super initWithFrame:CGRectMake(0, 0, BASE_WIDTH, BASE_HEIGHT + HEIGHT_MARGIN)];

    self.controller = nil;
    
    userRenderView = [[[UserRenderView alloc] initWithUser:theUser] retain];
    [self addSubview:userRenderView];
        
    self.bounds = CGRectMake(-BASE_WIDTH/2, -(BASE_HEIGHT + HEIGHT_MARGIN)/2, BASE_WIDTH, BASE_HEIGHT + HEIGHT_MARGIN);
    //    self.center = CGPointMake(500, 500);
    
    taskDrawerExtended = FALSE;
    userExtended = FALSE;
    
	//the + 11 was to hide the container view well under the user
    taskContainerView = [[[TaskContainerView alloc] initWithFrame:CGRectMake(-BASE_WIDTH, +15, BASE_WIDTH*2, 600) withRot:0.0 isMainView:NO] retain];
    [self addSubview:taskContainerView];
    

    // Why do I have to do this? Shouldn't the transform of the parent view do enough?
    // Maybe TaskContainerView has a weird default transform that it shouldn't have.    
//    [taskContainerView setTransform:CGAffineTransformMakeRotation(0)];
    [taskContainerView setRot:0];
    
    [self sendSubviewToBack:taskContainerView];
    
    self.exclusiveTouch = FALSE;
	
	taskContainerView.alpha = 0;
	[UIView beginAnimations:@"fade_in" context:taskContainerView];
	
	[UIView setAnimationDuration:.5f];
	
	taskContainerView.alpha = 1.0;
	
	
	[UIView commitAnimations];
    self.alpha = 0;
	[UIView beginAnimations:@"fade_in" context:self];
	
	[UIView setAnimationDuration:.3f];
	
	self.alpha = 1.0;
	
	
	[UIView commitAnimations];
	
    [self setNeedsDisplay];
    
//    UIView *centerDot = [[UIView alloc] initWithFrame:CGRectMake(-3, -3, 6, 6)];
//    centerDot.backgroundColor = [UIColor blackColor];
//    [self addSubview:centerDot];
    
    return self;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"touches ended on parent view");
}

- (void) userTouched {
    // toggle draw extended state.
    [self setDrawerExtended:!taskDrawerExtended];
    
    [controller userTaskDrawerExtended:self];
}

- (void) taskAssigned:(Task *)theTask {
    NSLog(@"Task assigned to user. Requesting redraw.");
    [taskContainerView addTaskView:[theTask getView]];
    
    [self setHoverState:false];
    [self setNeedsDisplay];
}

- (void) taskRemoved:(Task *)theTask {
    [theTask removeFromSuperview];
    [self setNeedsDisplay];
}

- (void) setNeedsDisplay {
    [super setNeedsDisplay];
    [userRenderView setNeedsDisplay];
    [taskContainerView setNeedsDisplay];
}

- (void) setHoverState:(bool)state {
 
    // Do something. 
    NSLog(@"setting hover state to %d on %@", state, userRenderView.user.name);
    userRenderView.hover = state;
    [userRenderView setNeedsDisplay];
}

// Figure out how to merge this into the .user format? Would be nice it it was transparent.
- (User *)getUser {
    return userRenderView.user;
}

- (void) setDrawerExtended:(bool)extended {
    if(extended != taskDrawerExtended) {
        // If this is a change in the current state, trigger an animation
        // to update the situation.
        
        // This is implied by the previous if, but making it
        // explicit for readability.
        if(taskDrawerExtended == false && extended==true) {
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
                    yExtendAmount =  taskContainerView.bounds.size.height + USER_EXTEND_HEIGHT + 50;
                    xExtendAmount =  taskContainerView.bounds.size.width - self.bounds.size.width;
                    
                    xOffsetAmount = ABS(taskContainerView.frame.origin.x - self.bounds.origin.x);
                    
                    drawerExtendAmount = yExtendAmount;
                    
                    taskContainerView.center = CGPointMake(taskContainerView.center.x, taskContainerView.center.y - yExtendAmount);
                    break;
                case 1:
                case 3:
                    yExtendAmount =  taskContainerView.bounds.size.width + USER_EXTEND_HEIGHT + 50;
                    xExtendAmount =  taskContainerView.bounds.size.height - self.bounds.size.width;

                    xOffsetAmount = ABS(taskContainerView.frame.origin.x - self.bounds.origin.x);

                    drawerExtendAmount = yExtendAmount;

                    
                    taskContainerView.center = CGPointMake(taskContainerView.center.x, taskContainerView.center.y - yExtendAmount);
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
            taskDrawerExtended = true;
            
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
            taskContainerView.frame = taskContainerViewInitialFrame;
                        
            self.frame = initialFrame;
            self.bounds = initialBounds;

            
            [UIView commitAnimations];        
            taskDrawerExtended = false;
            
            [controller setBackdropHidden:TRUE];
        }
        
        [self setUserExtended:extended withAutorevert:false];
    }
}


- (void) setUserExtended:(bool)extended withAutorevert:(bool)autorevert {
    if(extended != userExtended) {
        // If this is different than the current state, then trigger a change.
        // The cehange is going to be different depending on which direction
        // we're going, so check.
        
        [self setNeedsDisplay];
        
        doAutorevert = false;
                
        if(userExtended == false && extended == true) {
            // Do an extension.
            [UIView beginAnimations:@"extend_user" context:nil];
            [UIView setAnimationDuration:0.4f];
            
            userRenderView.center = CGPointMake(userRenderView.center.x, userRenderView.center.y-USER_EXTEND_HEIGHT);
            
            [UIView commitAnimations];
            userExtended = true;
        } else {
            // Do a retraction.
            [UIView beginAnimations:@"retract_user" context:nil];

            [UIView setAnimationDuration:0.4f];
            
            userRenderView.center = CGPointMake(userRenderView.center.x, userRenderView.center.y+USER_EXTEND_HEIGHT);
            
            [UIView commitAnimations];
            userExtended = false;
        }
        
        if(autorevert) {
            doAutorevert = true;
            [self performSelector:@selector(revertUserExtended) withObject:nil afterDelay:4];
        }
    }
    
}

 - (void) revertUserExtended {
     // If we get this call, check to see if we still need to do the reverting.
     // This is important so we don't flip states after someone has already
     // touched the user.
     if(!doAutorevert) {
         return;
     }
     
     [self setUserExtended:!userExtended withAutorevert:false];
     
     doAutorevert = false;
 }



- (NSComparisonResult) compareByLocation:(UserView *)view {
    // We want to group locations together and then within shared locations,
    // organize them alphabetically. When compareing locations, order those
    // alphabetically, too. 
    User *userA = userRenderView.user;
    User *userB = [view getUser];
    
    Location *locA = userA.location;
    Location *locB = userB.location;
    
    if([locA isEqual:locB]) {
        // If they're the same, then we sort based on user names.
        return [userA.name compare:userB.name];
    } else {
        return [locA.name compare:locB.name];
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
    taskContainerView.transform = CGAffineTransformMakeRotation(newRot);
    
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
            initialDrawerFrame = CGRectMake(-BASE_WIDTH, 15, BASE_WIDTH*2, 600);
            adjustLeftRight = true;
            adjustDirection = 1;
            break;
            
        case 2:
            initialDrawerFrame = CGRectMake(-BASE_WIDTH, 15, BASE_WIDTH*2, 600);
            adjustLeftRight = true;
            adjustDirection = -1;
            break;
            
        case 1:
            initialDrawerFrame = CGRectMake(-BASE_WIDTH, 15, 600, BASE_WIDTH*2);
            adjustTopBottom = true;
            adjustDirection = -1;
            break;
            
        case 3:
            initialDrawerFrame = CGRectMake(-BASE_WIDTH, 15, 600, BASE_WIDTH*2);
            adjustTopBottom = true;
            adjustDirection = 1;
            break;
    }
    
    taskContainerView.frame = initialDrawerFrame;
    globalBounds = [self convertRect:taskContainerView.frame toView:self.superview];
    
    
    distanceFromLeft = CGRectGetMinY(globalBounds) - CONTAINER_EDGE_OFFSET;
    distanceFromRight = CGRectGetMaxY(globalBounds) - 1024 + CONTAINER_EDGE_OFFSET;
    distanceFromTop = CGRectGetMaxX(globalBounds) - 768 + CONTAINER_EDGE_OFFSET;
    distanceFromBottom = CGRectGetMinX(globalBounds) - CONTAINER_EDGE_OFFSET;

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
        
    taskContainerView.frame = CGRectMake(taskContainerView.frame.origin.x + adjustment,
                                         taskContainerView.frame.origin.y,
                                         taskContainerView.frame.size.width,
                                         taskContainerView.frame.size.height);
    
    globalBounds = [self convertRect:taskContainerView.frame toView:self.superview];
    
    taskContainerViewInitialFrame = taskContainerView.frame;
}

- (void)dealloc {    
    [userRenderView release];
    [taskContainerView release];
    [super dealloc];
}


// Convenience method that gets used in a few different places to work
// around the event propegation problems we have when we put all the
// user views in a single UIView. Returns them sorted by location.

+ (NSArray *) getAllUserViews {
    // Get a list of users from the state manager.
    NSMutableSet *allUserViews = [NSMutableSet set];
    for (User *user in [StateManager sharedInstance].meeting.currentParticipants) {
        [allUserViews addObject:[user getView]];
    }

    return [[allUserViews allObjects] sortedArrayUsingSelector:@selector(compareByLocation:)];
}


@end
