//
//  TaskContainerView.h
//  TinCan
//
//  Created by Paula Jacobs on 8/4/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskDropTarget.h"
#import "AddItemController.h"

@interface TaskContainerView : UIView <TaskDropTarget, AddItemDelegate> {
    float rot;
    bool hover;
    bool isMainView;
    
    UIPopoverController *popoverController;
    bool buttonPressed;
    CGRect buttonRect;
}

- (void) setRot:(float) newRot;
- (id) initWithFrame:(CGRect)frame withRot:(float)rotation isMainView:(BOOL) mainView;

- (void) setHoverState:(bool)state;

@end
