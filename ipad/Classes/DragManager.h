//
//  DragManager.h
//  TinCan
//
//  Created by Drew Harry on 5/23/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Task.h"
#import "TaskView.h"

@interface DragManager : NSObject <TaskDragDelegate> {
    UIView *rootView;
    UIView *usersContainer;
    UIView *taskContainer;
    UIView *trashView;
    
    UIView *draggedItemsContainer;
    
    NSMutableDictionary *lastTaskDropTargets;
    
    CGAffineTransform originalTransform;
    
    
}


+ (DragManager*)sharedInstance;


- (UIView *) userViewAtPoint:(CGPoint)point;

- (void) setRootView:(UIView *)view andTaskContainer:(UIView *)theTaskContainer andTrashView:(UIView *)theTrashView;

- (void) taskDragAnimationComplete;
- (bool) moveTaskViewToDragContainer:(TaskView *)view;
- (void) animateTaskToHome:(Task *)theTask;


@property (nonatomic, retain) UIView *rootView;
@property (nonatomic, retain) UIView *usersContainer;
@property (nonatomic, retain) UIView *taskContainer;
@property (nonatomic, retain) UIView *trashView;

@end