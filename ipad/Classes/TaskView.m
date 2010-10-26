//
//  TaskView.m
//  TinCan
//
//  Created by Paula Jacobs on 8/3/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "TaskView.h"
#import "Task.h"
#import "DragManager.h"

@implementation TaskView

@synthesize task;
@synthesize delegate;
@synthesize lastParentView;

#define ASSIGN [NSNumber numberWithInt:0] 
#define DEASSIGN [NSNumber numberWithInt:1]

#define BAR_WIDTH 10
#define INSET_HEIGHT 4
#define INSET_BETWEEN_MARGIN 6
#define INSET_OUTER_MARGIN 3

- (id)initWithFrame:(CGRect)frame withTask:(Task *)theTask{
    if ((self = [super initWithFrame:frame])) {
		self.frame=frame;

		task = theTask;
        
        initialOrigin = CGPointMake(self.frame.origin.x, self.frame.origin.y);//self.frame.origin;  
		self.userInteractionEnabled = YES; 
		isTouched= FALSE;
		
        // Set our own delegate on init.
        self.delegate = [DragManager sharedInstance];
        
		self.alpha = 0;
		[UIView beginAnimations:@"fade_in" context:self];
		
		[UIView setAnimationDuration:.3f];
				
		self.alpha = 1.0;
		
		[UIView commitAnimations];
		
    }
    return self;
}

- (id) initWithTask:(Task *)theTask {
    return [self initWithFrame:CGRectMake(0, 0, 230, 50) withTask:theTask];
}

-(void)setFrameWidthWithContainerWidth:(CGFloat )width{
	self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, (width)-20, self.frame.size.height);
}

- (void)drawRect:(CGRect)rect {

    // Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	
	CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.5 alpha:1].CGColor);
	CGContextFillRect(ctx, CGRectMake(0, 0, BAR_WIDTH, self.frame.size.height));
    
    // Now draw the draggability bars here. Just do a series of lighter rects at first.
//    for(int i=0; i<floor(self.frame.size.height/(INSET_HEIGHT + INSET_BETWEEN_MARGIN)); i++) {
//        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.7 alpha:1.0].CGColor);
//        CGContextFillRect(ctx, CGRectMake(INSET_OUTER_MARGIN,
//                                          INSET_OUTER_MARGIN + i*(INSET_HEIGHT + INSET_BETWEEN_MARGIN),
//                                          BAR_WIDTH -2*INSET_OUTER_MARGIN, INSET_HEIGHT));
//        
//        // This is the bar at the top that makes it look inset.
//        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.4 alpha:1.0].CGColor);        
//        CGContextFillRect(ctx, CGRectMake(INSET_OUTER_MARGIN,
//                                          INSET_OUTER_MARGIN + i*(INSET_HEIGHT + INSET_BETWEEN_MARGIN),
//                                          BAR_WIDTH -2*INSET_OUTER_MARGIN, 1));
//    }
//    CGContextFillRect(ctx, CGRectMake(3, 3, BAR_WIDTH -6, 3));
//    CGContextFillRect(ctx, CGRectMake(3, 8, BAR_WIDTH -6, 3));
//    CGContextFillRect(ctx, CGRectMake(3, 13, BAR_WIDTH -6, 3));
//    CGContextFillRect(ctx, CGRectMake(3, 18, BAR_WIDTH -6, 3));
//
    
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);

    
	if(isTouched==FALSE){
	CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
	}
	else {
		CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1].CGColor );
	}

	CGContextFillRect(ctx, CGRectMake(BAR_WIDTH, 0, self.frame.size.width-12, self.frame.size.height));
	CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:1 green:1 blue:1 alpha:1].CGColor);
	[task.text drawInRect:CGRectMake(BAR_WIDTH + 5, 2, self.frame.size.width-16, self.frame.size.height) 
			withFont:[UIFont systemFontOfSize:16] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
	
	CGContextSetLineWidth(ctx,2);
	CGContextSetStrokeColorWithColor(ctx,  [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);
	CGContextStrokeRect(ctx, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
	
	[self setNeedsDisplay];

}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"I have been touched");
    UITouch *touch = [touches anyObject];

	isTouched=TRUE;
	//self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width-100, 50);
	[self setNeedsDisplay];
	[self.superview bringSubviewToFront:self];
    
    // retain this? can get away without it, right, since it's in the hierarchy and 
    // not going to get released any time soon?
    lastParentView = self.superview;
    
    [self.delegate taskDragStartedWithTouch:touch withEvent:event withTask:self.task];   
}


- (void) startAssignToUser:(User *)toUser byActor:(Actor *)byActor atTime:(NSDate *)assignTime {
    // Animate the task off the screen. 
    
    assignedToUser = [toUser retain];
    assignedByActor = [byActor retain];
    assignedAt = [assignTime retain];
    
    // Okay, first we have to make sure this view is already in the DragManager's dragged
    // items view. So we'll just tell the DragManager to take control of it, and let it
    // decide if it's already got control.
    if([[DragManager sharedInstance] moveTaskViewToDragContainer:self]) {
        // We need to kick off a transition that moves
        // the view on top of the UserView before we 
        // do the spinning/fading transition of assignment.
        [UIView beginAnimations:@"move_task_to_user" context:ASSIGN];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(moveTaskAnimationDone:finished:context:)];
        
        self.center = [self.superview convertPoint:[toUser getView].center fromView:[toUser getView].superview];
        
        [UIView commitAnimations];
        
    } else {
        // This is the fancy iOS 4.0+ way to do it, but ofc we don't have that API on the ipad yet.
        //    [UIView animateWithDuration:2.0
        //                     animations:^{
        //                         self.alpha = 0.4;
        //                         
        //                         // We want to move offscreen, but I'm not totally sure how to get the right point.
        //                         // First, lets just try to go to the user's center.
        //                         self.center = [toUser getView].center;
        //                         
        //                         // We also want to flip to be the right orientation as we fly off. 
        //                         [self setTransform:[toUser getView].transform];                         
        //                     }
        //                     completion: ^(BOOL finished) {
        //                         [self finishAssignToUser:toUser byActor:byActor atTime:assignTime];
        //                     }];
        
        
        [UIView beginAnimations:@"assign_task_to_user" context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(assignAnimationDone:finished:context:)];
        
        self.alpha = 0.0;
        
        [self setTransform:CGAffineTransformScale([toUser getView].transform, 0.3, 0.3)];
        
        [UIView commitAnimations];
    }
}

- (void) moveTaskAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    
    NSNumber *type = (NSNumber *)context;
    
    if([type intValue]==[ASSIGN intValue]) {
        [UIView beginAnimations:@"assign_task_to_user" context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(assignAnimationDone:finished:context:)];
        
        self.alpha = 0.0;
        
        [self setTransform:CGAffineTransformScale([assignedToUser getView].transform, 0.3, 0.3)];
        
        [UIView commitAnimations];
    } else if ([type intValue]==[DEASSIGN intValue]) {
        NSLog(@"***********IN DEASSIGN CALLBACK ROUTER");
        [UIView beginAnimations:@"deassign_task_from_user" context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(deassignAnimationDone:finished:context:)];
        
        self.alpha = 0.0;
        
        [self setTransform:CGAffineTransformScale(tempTaskContainer.transform, 0.3, 0.3)];
        
        [UIView commitAnimations];        
    }
}


// should I just fold all of the other method into here? or is it good to keep them conceptually separate?
- (void) assignAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    NSLog(@"in animation callback, about to finish assignment: %@, finished: %@", animationID, finished);
    [self finishAssignToUser:assignedToUser byActor:assignedByActor atTime:assignedAt];
    
    
    [assignedToUser release];
    assignedToUser = nil;
    [assignedByActor release];
    assignedByActor = nil;
    [assignedAt release];
    assignedAt = nil;
}

- (void) finishAssignToUser:(User *)toUser byActor:(Actor *)byActor atTime:(NSDate *)assignTime {
    
    self.alpha = 1.0;
    [self setTransform:CGAffineTransformMakeRotation(0.0)];
    // Remove the TaskView from its current super view and assign it to its new container.
    [[task getView] removeFromSuperview];
    
    [toUser assignTask:task];
    
    [task assignToUser:toUser byActor:byActor atTime:assignTime];
    
    isTouched = false;
    [[DragManager sharedInstance] taskDragAnimationComplete];
}


- (void) startDeassignByActor:(Actor *)byActor atTime:(NSDate *)assignTime withTaskContainer:(UIView *)taskContainer {
    
    assignedByActor = [byActor retain];
    assignedAt = [assignTime retain];
    tempTaskContainer = [taskContainer retain];
    
    
    if([[DragManager sharedInstance] moveTaskViewToDragContainer:self]) {
        // We need to kick off a transition that moves
        // the view on top of the UserView before we 
        // do the spinning/fading transition of assignment.
        [UIView beginAnimations:@"move_task_to_container" context:DEASSIGN];
        [UIView setAnimationDuration:1.0f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(moveTaskAnimationDone:finished:context:)];
        
        self.center = [self.superview convertPoint:taskContainer.center fromView:taskContainer.superview];
        
        [UIView commitAnimations];
    } else {
        
        [UIView beginAnimations:@"deassign_task_from_user" context:nil];
        [UIView setAnimationDuration:0.5f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(deassignAnimationDone:finished:context:)];
        
        self.alpha = 0.0;
        
        [self setTransform:CGAffineTransformScale(taskContainer.transform, 0.3, 0.3)];
        
        [UIView commitAnimations];
    }
}

- (void) deassignAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [self finishDeassignByActor:assignedByActor atTime:assignedAt withTaskContainer:tempTaskContainer];    
    
    [assignedByActor release];
    assignedByActor = nil;
    [assignedAt release];
    assignedAt = nil;
    [tempTaskContainer release];
    tempTaskContainer = nil;
}

- (void) finishDeassignByActor:(Actor *)byActor atTime:(NSDate *)assignTime withTaskContainer:(UIView *)taskContainer {
    self.alpha = 1.0;

    [[task getView] removeFromSuperview];
    [self setTransform: CGAffineTransformMakeRotation(0.0)];
    [taskContainer addSubview:[task getView]];
    
    [task.assignedTo removeTask:task];
    
    [task deassignByActor:byActor atTime:assignTime];    

    isTouched = false;
    [[DragManager sharedInstance] taskDragAnimationComplete];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	// When we move, we want to know the delta from its previous location
	// and then we can adjust our position accordingly. 
	
	UITouch *touch = [touches anyObject];
	
	float dX = [touch locationInView:self.superview].x - [touch previousLocationInView:self.superview].x;
	float dY = [touch locationInView:self.superview].y - [touch previousLocationInView:self.superview].y;
	self.center = CGPointMake(self.center.x + dX, self.center.y + dY);
	
	[self setNeedsDisplay];

    
    // Inform the delegate.
    [self.delegate taskDragMovedWithTouch:touch withEvent:event withTask:self.task];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    // TODO think about multitouch for this!
    UITouch *touch = [touches anyObject];
    
    if (![self.delegate taskDragEndedWithTouch:touch withEvent:event withTask:self.task]) {
                
        [UIView beginAnimations:@"snap_to_initial_position" context:nil];
        
        [UIView setAnimationDuration:1.0f];
        
        CGRect newFrame = self.frame;
        newFrame.origin = CGPointMake(initialOrigin.x, initialOrigin.y);
        self.frame = newFrame;
        NSLog(@"animating to initialOrigin: %f, %f", initialOrigin.x, initialOrigin.y);
		[self.superview setNeedsLayout];
        [UIView commitAnimations];
		isTouched=FALSE;
		[self.superview sendSubviewToBack:self];
    } else {
            // We were dropped on an actual drop target. Something else will handle our
            // animation at this point (although we should think about moving it here for
            // consistency.
        NSLog(@"dropped on drop target.");
    }
    

		[self setNeedsDisplay];
}

- (NSComparisonResult) compareByPointer:(TaskView *)view {
    
    // Tries to comare by strings, but if they end up being exactly the same string,
    // it will resolve the ties by comparing pointers. This is a deterministic comparison
    // and an arbitrary (but stable) way to tell between tasks with identical text.
    // This is a rare case in real use, but happens a lot in testing, so this gives us some
    // protection from bad issues during demoing.
        
    NSComparisonResult retVal = [self.task.text compare:view.task.text];
    
    if(retVal==NSOrderedSame) {
        if (self < view)
            retVal = NSOrderedAscending;
        else if (self > view) 
            retVal = NSOrderedDescending;
    }
    
    return retVal;
}

- (void)dealloc {
    [super dealloc];
}


@end
