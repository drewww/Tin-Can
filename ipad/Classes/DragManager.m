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

#pragma mark -
#pragma mark class instance methods


- (id) init {
    
    self = [super init];
    
    lastTaskDropTargets = [[NSMutableDictionary dictionary] retain];
   
    return self;
}

- (void) setRootView:(UIView *)view andUsersContainer:(UIView *)container {
    
    self.rootView = view;
    self.usersContainer = container;    
}


- (UserView *) userViewAtTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint point = [touch locationInView:self.rootView];
    
    UIView *returnedView = [self.usersContainer hitTest:point withEvent:event];
        
    if(returnedView==nil) {
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

- (void) taskDragMovedWithTouch:(UITouch *)touch withEvent:(UIEvent *)event withTask:(Task *)task{
    
    // Get the last target
    UserView *lastDropTarget = [lastTaskDropTargets objectForKey:task.uuid];
    
    // Now check and see if we're over a participant right now.
	UserView *curDropTarget = [self userViewAtTouch:touch withEvent:event];

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
	

	// Why was this code ever here? This seems totally naive and wrong.
//	[lastDropTarget setHoverState:false];
//	[lastDropTarget release];
//	if(curDropTarget !=nil) {
//		[curDropTarget setHoverState:true];
//		lastDropTarget = curDropTarget;
//		[lastDropTarget retain];
//	}
    
    // Now push the current last into the dictionary.
    [lastTaskDropTargets setValue:lastDropTarget forKey:task.uuid];
}

- (bool) taskDragEndedWithTouch:(UITouch *)touch withEvent:(UIEvent *)event withTask:(Task *)task {
    // Get the current target
    UserView *curTargetView = [self userViewAtTouch:touch withEvent:event];	
    
    // Assign the Task.
    if(curTargetView != nil) {
        
        // Do the actual task assignment.
        [(TaskView *)[task getView] startAssignToUser:[curTargetView getUser] byActor:[StateManager sharedInstance].location atTime:[NSDate date]];
        
        // Send the message to the server that the task has been assigned.
        // We're doing this here and not in any of the other model-based methods beacuse those
        // are going to be called when assignment happens on other clients, and we want to avoid
        // triggering a cascade. This chunk of code only gets called for the client that
        // physically does the assignment.
        [[ConnectionManager sharedInstance] assignTask:task toUser:[curTargetView getUser]];
        
        return true;
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
