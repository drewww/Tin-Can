//
//  TaskView.h
//  TinCan
//
//  Created by Paula Jacobs on 8/3/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"


//@class TaskDragDelegate;

@protocol TaskDragDelegate
- (void) taskDragMovedWithTouch:(UITouch *)touch withEvent:(UIEvent *)event withTask:(Task *)task;

// Returns true if the drag ended on a drop target, false otherwise.
// (TODO should this actually return the target we dropped on instead of just true/false?)
// (alternatively, should we have a generic drop target interface? Hmm.)
- (bool) taskDragEndedWithTouch:(UITouch *)touch withEvent:(UIEvent *)event withTask:(Task *)task;
@end

@interface TaskView : UIView {
	CGPoint    initialOrigin;
	bool isTouched; 
    Task *task;
    
    // A delegate (the drag manager) to be notified of drag operations.
    id <TaskDragDelegate> delegate;
}

@property (nonatomic, readonly) Task *task;
@property (nonatomic, assign) id <TaskDragDelegate> delegate;


- (id)initWithFrame:(CGRect)frame withTask:(Task *)task;
- (id)initWithTask:(Task *)theTask;

- (NSComparisonResult) compareByPointer:(TaskView *)view;
-(void)setFrameWidthWithContainerWidth:(CGFloat )width;

@end
