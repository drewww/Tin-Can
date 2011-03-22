//
//  TaskContainerContentView.h
//  TinCan
//
//  Created by Drew Harry on 2/25/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaskView.h"

@interface TaskContainerContentView : UIView {
    bool isMainView;
}

- (id)initWithFrame:(CGRect)frame isMainView:(bool)setIsMainView;
- (void) taskViewExpanded:(TaskView *)viewExpanded;

@property (nonatomic, assign) bool isMainView;

@end
