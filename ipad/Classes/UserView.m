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

#define USER_EXTEND_HEIGHT 40

@synthesize side;

- (id) initWithUser:(User *)theUser {

    self = [super initWithFrame:CGRectMake(0, 0, BASE_WIDTH, BASE_HEIGHT + HEIGHT_MARGIN)];

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
    // The 14 was to make sure the container was well above the label
	initialHeight = taskContainerView.bounds.size.height+14+40;

	
    return self;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSLog(@"touches ended on parent view");
}

- (void) userTouched {
    // toggle draw extended state.
    [self setDrawerExtended:!taskDrawerExtended];
}

- (void) taskAssigned:(Task *)theTask {
    NSLog(@"Task assigned to user. Requesting redraw.");
    [taskContainerView addSubview:[theTask getView]];
    
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
            
            //float initialHeight = taskContainerView.bounds.size.height;
            
            // TODO make this an absolute position, not an adjustment.
            taskContainerView.center = CGPointMake(taskContainerView.center.x, taskContainerView.center.y - initialHeight - USER_EXTEND_HEIGHT);
            
            CGRect curFrame = self.bounds;
            curFrame.origin.y = curFrame.origin.y - (initialHeight+USER_EXTEND_HEIGHT);
            curFrame.size.height = curFrame.size.height + (initialHeight + USER_EXTEND_HEIGHT)*2;
            self.bounds = curFrame;
            
            // Save the amount we changed the dimensions by so the retract can make
            // sure to move the same amount back. This is going to be most important
            // in situations where the container changes sizes (ie a task was removed)
            lastHeightChange = initialHeight + USER_EXTEND_HEIGHT;
            
            [UIView commitAnimations];
            taskDrawerExtended = true;
        } else {
            // in this situation, we can be sure that
            // taskDrawerExtended == true && extended == false
            [UIView beginAnimations:@"retract_drawer" context:nil];
            
            [UIView setAnimationDuration:0.4f];
            taskContainerView.center = CGPointMake(taskContainerView.center.x, taskContainerView.center.y + lastHeightChange);
            
            CGRect curFrame = self.bounds;
            curFrame.origin.y = curFrame.origin.y + lastHeightChange;
            curFrame.size.height = curFrame.size.height - lastHeightChange*2;
            self.bounds = curFrame;
            
            [UIView commitAnimations];        
            taskDrawerExtended = false;
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
