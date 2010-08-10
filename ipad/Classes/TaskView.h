//
//  TaskView.h
//  TinCan
//
//  Created by Paula Jacobs on 8/3/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Task.h"

@interface TaskView : UIView {
	NSString *text;
	CGPoint    initialOrigin;
	bool isTouched; 
    Task *task;
}

@property (nonatomic, retain) NSString *text;



- (id)initWithFrame:(CGRect)frame withText:(NSString *)task;
- (id)initWithTask:(Task *)theTask;

- (NSComparisonResult) compareByPointer:(TaskView *)view;
-(void)setFrameWidthWithContainerWidth:(CGFloat )width;

@end
