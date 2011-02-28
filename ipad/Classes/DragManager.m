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

- (void) setRootView:(UIView *)view andTaskContainer:(TaskContainerView *)theTaskContainer{
    
    self.rootView = view;
    self.taskContainer = theTaskContainer;
    
    draggedItemsContainer = [[UIView alloc] initWithFrame:self.rootView.frame];
    [draggedItemsContainer setTransform:CGAffineTransformMakeRotation(M_PI/2)];
    
    [self.rootView addSubview:draggedItemsContainer];
    [self.rootView bringSubviewToFront:draggedItemsContainer];
    
}


- (UIView <TaskDropTarget> *) userViewAtPoint:(CGPoint)point {
        
    // TODO We'll need to hit-test the taskContainer separately here, which is annoying, unless
    // we add it to the UsersContainer. 
    
    // Hit test against all users.
    UIView *returnedView = nil;
    for (UserView *view in [UserView getAllUserViews]) {
        
        if(CGRectContainsPoint(view.frame, point)) {
            returnedView = view;
            break;
        }
    }
    
    if([taskContainer pointInside:[taskContainer convertPoint:point fromView:self.rootView] withEvent:nil]) {
        NSLog(@"point in task container, returning that!");
        return taskContainer;
    }
    
    UIView *potentialTaskContainer = [self.taskContainer hitTest:point withEvent:nil];

    
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

- (void) taskDragStartedWithGesture:(UIGestureRecognizer *)gesture withTask:(Task *)task{
    // When we get the first touch, pull it out of its current superview and put it on the root view.
    // We'll push it back when it gets dropped again.    
    TaskView *taskView = (TaskView *)[task getView];

    // Try making the task subtly bigger to make it feel like you've picked it up.
    taskView.frame = CGRectInset(taskView.frame, -5, -5);
    [taskView setNeedsDisplay];
    
    [self moveTaskViewToDragContainer:taskView];
}

- (void) taskDragMovedWithGesture:(UIGestureRecognizer *)gesture withTask:(Task *)task {
    
    // Get the last target
    UIView <TaskDropTarget> *lastDropTarget = [lastTaskDropTargets objectForKey:task.uuid];
    
    // Now check and see if we're over a participant right now.
	UIView <TaskDropTarget> *curDropTarget = [self userViewAtPoint:[gesture locationOfTouch:0 inView:self.rootView]];

	// if cur and last are the same, do nothing.
	// if they're different, release the old and retain the new and manage states.
	// if cur is nothing and last is something, release and set false
	// if cur is something and last is nothing, retain and set true
	
//    NSLog(@"Drop targets: (last) %@ =? %@ (cur)", lastDropTarget, curDropTarget);

    // This disables highlighting users when we drag tasks over them. 
    // Going to add a special check for the trash in a sec.
    if([curDropTarget isKindOfClass:[UserView class]]) return;
    
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

- (bool) taskDragEndedWithGesture:(UIGestureRecognizer *)gesture withTask:(Task *)task {
    // Get the current target
    UIView <TaskDropTarget> *curTargetView = [self userViewAtPoint:[gesture locationOfTouch:0 inView:self.rootView]];	
    
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
            
            // Commenting this out to disable assigning ideas to other users (per classroom design spec)
//            UserView *curTargetUserView = (UserView *)curTargetView;
//            [[ConnectionManager sharedInstance] assignTask:task toUser:[curTargetUserView getUser]];
//            [curTargetView setHoverState:false];
            
            [self animateTaskToHome:task];
            
        } else if ([curTargetView isKindOfClass:[TaskContainerView class]]) {
            NSLog(@"got a drop on a task container, copy the task now!");
            
            
            // Per the classroom "idea" model, don't move the idea over, just create a new one
            // that is unassigned.
            Topic *currentTopic = [[StateManager sharedInstance].meeting getCurrentTopic];
            UIColor *theColor = nil;
            if (currentTopic != nil) {
                theColor = currentTopic.color;
            }
            
            [[ConnectionManager sharedInstance] addTaskWithText:task.text isInPool:TRUE
                                                    isCreatedBy:task.creator.uuid
                                                   isAssignedBy:[StateManager sharedInstance].user.uuid
                                                      withColor:theColor];
            
            [self animateTaskToHome:task];
            
            [curTargetView setHoverState:false];
        }
        return true;
    } else {
     // We need to add it back to its original home view. 
        [self animateTaskToHome:task];
        
    }
    
    return false;
}

- (void) animateTaskToHome:(Task *)task {
    NSLog(@"Adding the task back to its original parent view since dragging is done.");
    TaskView *taskView = (TaskView *)[task getView];
    
    // Do the position translation back again.
    CGPoint p = [taskView.lastParentView convertPoint:taskView.center fromView:draggedItemsContainer];
    taskView.center = p;
    
    [taskView.lastParentView addSubview:taskView];
    
    NSLog(@"setting draggedItemsContainer to hidden");
    [draggedItemsContainer setHidden:true];
}

- (bool) moveTaskViewToDragContainer:(TaskView *)view {
    
    NSLog(@"unhiding the items container");
    [draggedItemsContainer setHidden:false];
    [draggedItemsContainer.superview bringSubviewToFront:draggedItemsContainer];

    if([draggedItemsContainer.subviews containsObject:view]) {
        NSLog(@"TaskView already in draggedItemsContainer.");
        return false;
    }
        
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
    
    // (bonus twist - if it's a user owned task, we do this - if it's
    // a task manager owned one, we don't)
    
    // Knocking out the transforms now, since everything should be facing up.
    if(view.task.assignedTo == nil) {
        [draggedItemsContainer addSubview:view];
//        [draggedItemsContainer setTransform:CGAffineTransformMakeRotation(M_PI/2)];
        CGPoint p = [draggedItemsContainer convertPoint:view.center fromView:view.lastParentView]; 
        NSLog(@"Point in draggedItemsContainer perspective: (%f, %f)", p.x, p.y);
        NSLog(@"current center: (%f, %f)", view.center.x, view.center.y);
        view.center = p;        
    } else {            
        [draggedItemsContainer addSubview:view];
//        [draggedItemsContainer setTransform:transform];
        CGPoint p = [draggedItemsContainer convertPoint:view.center fromView:view.lastParentView];    
        view.center = p;
    }
    
    // Return true if we did successfully move the view to the draggedItemsContainer view.
    // If it was already there, we returned false up top.
    
    // Close all the draw of the user that owns the task right now for visibility reasons.
    [((UserView *)[view.task.assignedTo getView]) setDrawerExtended:false];
    
    return true;
}

- (void) taskDragAnimationComplete {
    [draggedItemsContainer setHidden:true];   
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
