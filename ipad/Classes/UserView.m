//
//  UserView.m
//  TinCan
//
//  Created by Drew Harry on 8/5/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "UserView.h"
#import "UIColor+Util.h"

@implementation UserView

// This class is a shell - most of the real heavy lifting happens in the UserRenderView. See
// that class for a discussion about why there are two classes for user drawing.

- (id) initWithUser:(User *)theUser {

    self = [super initWithFrame:CGRectMake(0, 0, BASE_WIDTH, BASE_HEIGHT + HEIGHT_MARGIN)];

    userRenderView = [[[UserRenderView alloc] initWithUser:theUser] retain];
    [self addSubview:userRenderView];
        
    self.bounds = CGRectMake(-BASE_WIDTH/2, -(BASE_HEIGHT + HEIGHT_MARGIN)/2, BASE_WIDTH, BASE_HEIGHT + HEIGHT_MARGIN);
    //    self.center = CGPointMake(500, 500);
    
    taskDrawerExtended = FALSE;
    
	//the + 11 was to hide the container view well under the user
    taskContainerView = [[[TaskContainerView alloc] initWithFrame:CGRectMake(-BASE_WIDTH/2, -BASE_HEIGHT/2 +11, BASE_WIDTH, 300) withRot:0.0] retain];
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
	initialHeight = taskContainerView.bounds.size.height+14;

	
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
            taskContainerView.center = CGPointMake(taskContainerView.center.x, taskContainerView.center.y - initialHeight);
            
            CGRect curFrame = self.bounds;
            curFrame.origin.y = curFrame.origin.y - (initialHeight);
            curFrame.size.height = curFrame.size.height + (initialHeight)*2;
            self.bounds = curFrame;
            
            // Save the amount we changed the dimensions by so the retract can make
            // sure to move the same amount back. This is going to be most important
            // in situations where the container changes sizes (ie a task was removed)
            lastHeightChange = initialHeight;
            
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
    }
}

- (void)dealloc {
    
    [userRenderView release];
    [taskContainerView release];
    [super dealloc];
    
}


@end
