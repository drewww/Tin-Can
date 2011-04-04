//
//  TaskContainerContentView.m
//  TinCan
//
//  Created by Drew Harry on 2/25/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "TaskContainerContentView.h"
#import "TaskView.h"


@implementation TaskContainerContentView

@synthesize isMainView;

- (id)initWithFrame:(CGRect)frame isMainView:(bool)setIsMainView {
    
    self = [super initWithFrame:frame];
    if (self) {
        isMainView = setIsMainView;
    }
    return self;
}

- (void)layoutSubviews{
    NSLog(@"laying out task container with %d subviews", [[self subviews] count]);
    NSArray *sortedArray = [[self subviews] sortedArrayUsingSelector:@selector(compareByCreationDate:)];
    
    float taskHeight;
    float taskMargin = 3.5;
    
//    if(isMainView) {
//        taskHeight = 100.0;
//    } else {
//        taskHeight = 50.0;
//    }
    
    float accumulatedHeight = 0.0;
    
//    int maxVisibleTasks = floor(self.bounds.size.height/(taskHeight + taskMargin*2));
	for(TaskView *subview in [sortedArray reverseObjectEnumerator]){

        taskHeight = [subview getHeightForWidth:self.bounds.size.width-14];

        // Make sure lastParentViews are up to date.
        subview.lastParentView = self;
        
        // This is not properly abstracted. 60 is, I assume, the height of
        // one full-size task + its margins. Except that 
        
//        if(i<maxVisibleTasks) {
			NSLog(@"laying out task: %@", subview.task.text);
            [subview setHidden:FALSE];
			subview.frame=CGRectMake(7, taskMargin + accumulatedHeight, (self.bounds.size.width)-14, taskHeight);
//		} else {
//            [subview setHidden:TRUE];
//        }
		
		[subview setNeedsDisplay];
        
		NSLog(@"Subview frame: %@",NSStringFromCGRect(subview.frame));
    
        
        accumulatedHeight += taskHeight+taskMargin*2;
        
        NSLog(@"accumulatedHeight: %f", accumulatedHeight);
	}
	
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, (taskHeight + taskMargin)*[[self subviews]count] + taskMargin);
    NSLog(@"Frame: %@",NSStringFromCGRect(self.frame));
    
    
    if([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *parentScrollView = (UIScrollView *)self.superview;
        parentScrollView.contentSize = self.bounds.size;
        
    }
}

- (void) taskViewExpanded:(TaskView *)viewExpanded {
    for (TaskView *taskView in self.subviews) {
        if(taskView != viewExpanded) {
            taskView.expanded = false;
        }
    }
    
}

- (void) setNeedsDisplay {
    for(UIView *view in self.subviews) {
        [view setNeedsDisplay];
    }
}

- (void)dealloc {
    [super dealloc];
}


@end
