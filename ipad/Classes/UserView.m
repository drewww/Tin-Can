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
    
    taskContainerView = [[[TaskContainerView alloc] initWithFrame:CGRectMake(-BASE_WIDTH/2, -BASE_HEIGHT/2 + 10, BASE_WIDTH, BASE_HEIGHT)] retain];
    [self addSubview:taskContainerView];
    

    // Why do I have to do this? Shouldn't the transform of the parent view do enough?
    // Maybe TaskContainerView has a weird default transform that it shouldn't have.    
//    [taskContainerView setTransform:CGAffineTransformMakeRotation(0)];
    [taskContainerView setRot:0];
    
    [self sendSubviewToBack:taskContainerView];
    
    [self setNeedsDisplay];
    
    return self;
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    showStatus = !showStatus;
//    [self setNeedsDisplay];
//    
    
    // animate the task drawer into position
    if(!taskDrawerExtended) {
        [UIView beginAnimations:@"extend_drawer" context:nil];
    
        [UIView setAnimationDuration:0.4f];
        taskContainerView.center = CGPointMake(taskContainerView.center.x, taskContainerView.center.y - 250);
        
        [UIView commitAnimations];
        taskDrawerExtended = true;
    } else {
        [UIView beginAnimations:@"retract_drawer" context:nil];
        
        [UIView setAnimationDuration:0.4f];
        taskContainerView.center = CGPointMake(taskContainerView.center.x, 0);
        
        [UIView commitAnimations];        
        taskDrawerExtended = false;
    }
    
}

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	// We want to do our hit test a little differently - just return true
	// if it's inside the circle part of the participant rendering.
	CGFloat distance = sqrt(pow(point.x, 2) + pow(point.y, 2));
    
	if (distance <= 130.0f) {
		return self;	
	}
	else {
		return nil;
	}
}

- (void)dealloc {
    
    [userRenderView release];
    [taskContainerView release];
    [super dealloc];
    
}


@end
