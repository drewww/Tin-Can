//
//  DragManager.m
//  TinCan
//
//  Created by Drew Harry on 5/23/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "DragManager.h"
#import "Task.h"
#import "UserView.h"
#import "ASIFormDataRequest.h"
#import "ConnectionManager.h"

@implementation DragManager

static DragManager *sharedInstance = nil;

@synthesize rootView;
@synthesize usersContainer;
@synthesize taskContainer;

#pragma mark -
#pragma mark class instance methods


- (id) init {
    
    self = [super init];
    
    lastTaskDropTargets = [[NSMutableDictionary dictionary] retain];
   
    return self;
}

- (void) setRootView:(UIView *)view andUsersContainer:(UIView *)container andTaskContainer:(TaskContainerView *)theTaskContainer{
    
    self.rootView = view;
    self.usersContainer = container;
    self.taskContainer = theTaskContainer;
    
    draggedItemsContainer = [[UIView alloc] initWithFrame:self.rootView.frame];
    [draggedItemsContainer setTransform:CGAffineTransformMakeRotation(M_PI/2)];
    
    [self.rootView addSubview:draggedItemsContainer];
    [self.rootView bringSubviewToFront:draggedItemsContainer];
    
}


- (UIView <TaskDropTarget> *) userViewAtTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint point = [touch locationInView:self.rootView];
    
    // TODO We'll need to hit-test the taskContainer separately here, which is annoying, unless
    // we add it to the UsersContainer. 
    UIView *returnedView = [self.usersContainer hitTest:point withEvent:event];
    
    if([taskContainer pointInside:[taskContainer convertPoint:point fromView:self.rootView] withEvent:event]) {
        NSLog(@"point in task container, returning that!");
        return taskContainer;
    }
    
    UIView *potentialTaskContainer = [self.taskContainer hitTest:point withEvent:event];

    
    if(returnedView==nil && potentialTaskContainer==nil) {
        return nil;
    }
    
    if([returnedView isKindOfClass:[UserView class]]) {
        return ((UserView *) returnedView);
    } else if ([returnedView isKindOfClass:[UserRenderView class]]) {
        
        // This is a bit convoluted - should the RenderView have a ref
        // back to its parent?
        return (UserView *)[((UserRenderView *) returnedView).user getView];
        
    } else {
        return nil;
    }
}


#pragma mark TaskDragDelegate

- (void) taskDragStartedWithTouch:(UITouch *)touch withEvent:(UIEvent *)event withTask:(Task *)task {
    // When we get the first touch, pull it out of its current superview and put it on the root view.
    // We'll push it back when it gets dropped again.
    
    [draggedItemsContainer.superview bringSubviewToFront:draggedItemsContainer];
    NSLog(@"unhiding the items container");
    [draggedItemsContainer setHidden:false];
    
    TaskView *taskView = (TaskView *)[task getView];
    
     // NSLog(@"current center: (%f,%f), center in global coords: (%f, %f)", taskView.center.x, taskView.center.y, p.x, p.y);
          
    
    // Grab the UserView's transform.
    CGAffineTransform transform = taskView.superview.superview.transform;
    
    // (it occurs to me that this will likely cause problems when
    // I start animating TaskViews into their final destinations.)
    
    // Also, this is going to have troubles with dragging multiple tasks at once. 
    // Not going to stress about that for now, but might need to turn
    // off multi-touch explicitely to avoid issues?
    
    // Okay, this dance is a bit wacky. I had a really hard time getting
    // TaskViews to not rotate back to the default rotation when they're
    // picked up. This is a problem for users with non-default rotations.
    // For some reason if I grabbed the UserView's rotation (which is
    // .superview.superview), and applied it directly to the TaskView
    // it didn't seem to do anything. Applying it to the parent view 
    // (ie draggedItemsContainer) works fine, but you have to be careful
    // about the order. Have to make suer to convert the point AFTER
    // the transform is applied so it gets the right post-transform
    // point.
    [draggedItemsContainer addSubview:[task getView]];
    [draggedItemsContainer setTransform:transform];
    CGPoint p = [draggedItemsContainer convertPoint:taskView.center fromView:taskView.lastParentView];    
    taskView.center = p;
}

- (void) taskDragMovedWithTouch:(UITouch *)touch withEvent:(UIEvent *)event withTask:(Task *)task {
    
    // Get the last target
    UIView <TaskDropTarget> *lastDropTarget = [lastTaskDropTargets objectForKey:task.uuid];
    
    // Now check and see if we're over a participant right now.
	UIView <TaskDropTarget> *curDropTarget = [self userViewAtTouch:touch withEvent:event];

	// if cur and last are the same, do nothing.
	// if they're different, release the old and retain the new and manage states.
	// if cur is nothing and last is something, release and set false
	// if cur is something and last is nothing, retain and set true
	
//    NSLog(@"Drop targets: (last) %@ =? %@ (cur)", lastDropTarget, curDropTarget);
    
	if(curDropTarget != nil) {
		if (lastDropTarget == nil) {
//            NSLog(@" entering new drop target");
			[curDropTarget setHoverState:true];
			[curDropTarget retain];
			lastDropTarget = curDropTarget;			
		} else if(curDropTarget != lastDropTarget) {
            
//            NSLog(@"transitioning from one drop target to a different one");
            
			// transition.
			[lastDropTarget setHoverState:false];
			[lastDropTarget release];
            
			// No matter what, we want to set the current one true
			[curDropTarget setHoverState:true];
			[curDropTarget retain];
			lastDropTarget = curDropTarget;
		}
		
		// If they're the same, do nothing - don't want to be sending the
		// retain count through the roof.
	} else {
		// curTargetView IS nil.
		if(lastDropTarget != nil) {
            
//            NSLog(@"transitioning out of drop target to nothing");
            
			[lastDropTarget setHoverState:false];
			[lastDropTarget release];		
			lastDropTarget = nil;
		}
		
		// If they're both nil, do nothing.
	}
	    
    // Now push the current last into the dictionary.
    [lastTaskDropTargets setValue:lastDropTarget forKey:task.uuid];
}

- (bool) taskDragEndedWithTouch:(UITouch *)touch withEvent:(UIEvent *)event withTask:(Task *)task {
    // Get the current target
    UIView <TaskDropTarget> *curTargetView = [self userViewAtTouch:touch withEvent:event];	
    
    // Assign the Task.
    if(curTargetView != nil) {
        
        // Get a reference to the current user view, so we can tell it to retract its
        // drawer.
        UserView *previousOwnerUserView = (UserView *)[task.assignedTo getView];
        [previousOwnerUserView setDrawerExtended:false];
        
        // Send the message to the server that the task has been assigned.
        // We're doing this here and not in any of the other model-based methods beacuse those
        // are going to be called when assignment happens on other clients, and we want to avoid
        // triggering a cascade. This chunk of code only gets called for the client that
        // physically does the assignment.
        
        if([curTargetView isKindOfClass:[UserView class]]) {
            UserView *curTargetUserView = (UserView *)curTargetView;
            [[ConnectionManager sharedInstance] assignTask:task toUser:[curTargetUserView getUser]];
            [curTargetView setHoverState:false];
        } else if ([curTargetView isKindOfClass:[TaskContainerView class]]) {
            NSLog(@"got a drop on a task container, deassign the task now!");
            [[ConnectionManager sharedInstance] deassignTask:task];
            [curTargetView setHoverState:false];
        }
        
        [draggedItemsContainer setHidden:true];
        return true;
    } else {
     // We need to add it back to its original home view. 
    
        NSLog(@"Adding the task back to its original parent view since dragging is done.");
        TaskView *taskView = (TaskView *)[task getView];
        
        // Do the position translation back again.
        CGPoint p = [taskView.lastParentView convertPoint:taskView.center fromView:draggedItemsContainer];
        taskView.center = p;

        [taskView.lastParentView addSubview:taskView];
        
        NSLog(@"setting draggedItemsContainer to hidden");
        [draggedItemsContainer setHidden:true];

//        [draggedItemsContainer.superview sendSubviewToBack:draggedItemsContainer];
    }
    
    return false;
}


#pragma mark -
#pragma mark Singleton methods

+ (DragManager*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
            sharedInstance = [[DragManager alloc] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
