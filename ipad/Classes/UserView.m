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

- (id) initWithUser:(User *)theUser {

    TaskContainerView *taskContainerView = [[[TaskContainerView alloc] initWithFrame:CGRectMake(-[self getBaseWidth], +15, [self getBaseWidth]*2, 600) withRot:0.0 isMainView:NO] autorelease];
    [taskContainerView setRot:0.0];
    
    self = [super initWithFrame:CGRectMake(0, 0, [self getBaseWidth], [self getBaseHeight] + HEIGHT_MARGIN) withDrawerView:taskContainerView];

    self.controller = nil;
    
    userRenderView = [[[UserRenderView alloc] initWithUser:theUser] retain];
    [self addSubview:userRenderView];
        
    self.bounds = CGRectMake(-[self getBaseWidth]/2, -([self getBaseHeight] + HEIGHT_MARGIN)/2, [self getBaseWidth], [self getBaseHeight] + HEIGHT_MARGIN);
    //    self.center = CGPointMake(500, 500);
    
    userExtended = FALSE;
    
    self.exclusiveTouch = FALSE;
	
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
    [self setDrawerExtended:!drawerExtended];
    
    [controller userTaskDrawerExtended:self];
}

- (void) taskAssigned:(Task *)theTask {
    NSLog(@"Task assigned to user. Requesting redraw.");
    
    // Gonna need to do something about this - casting the drawer to what it's known to be
    // for this subclass. Or rather, we'll make it in the subclass. 
    [(TaskContainerView *)drawerView addTaskView:[theTask getView]];
    
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
    [super setDrawerExtended:extended];
    [self setUserExtended:extended withAutorevert:false];
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



- (void)dealloc {    
    [userRenderView release];
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
