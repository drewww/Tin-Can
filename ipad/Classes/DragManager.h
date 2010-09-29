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
    
    UIView *draggedItemsContainer;
    
    NSMutableDictionary *lastTaskDropTargets;
}


+ (DragManager*)sharedInstance;


- (UIView *) userViewAtTouch:(UITouch *)touch withEvent:(UIEvent *)event;

- (void) setRootView:(UIView *)view andUsersContainer:(UIView *)container;

- (void) taskDragMovedWithTouch:(UITouch *)touch withEvent:(UIEvent *)event withTask:(Task *)task;
- (bool) taskDragEndedWithTouch:(UITouch *)touch withEvent:(UIEvent *)event withTask:(Task *)task;


@property (nonatomic, retain) UIView *rootView;
@property (nonatomic, retain) UIView *usersContainer;


@end