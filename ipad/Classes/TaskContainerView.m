//
//  TaskContainerView.m
//  TinCan
//
//  Created by Paula Jacobs on 8/4/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "TaskContainerView.h"
#import "TaskView.h"

@implementation TaskContainerView

// TODOS
// To make this class work as both the main task view that holds unassigned tasks as well as
// the view that each user has that stores that user's tasks, there are some changes we need
// to make.
// 
// 1. Add a getHeight method that returns the view's desired height for the current number of
//    tasks it contains.
// 2. Force contained tasks to be the width of the container (minus 2*the padding)
// 3. We might need to do add/remove task by UUID for ease of use.

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        self.frame=frame;
                
        rot = M_PI/2;

		[self setNeedsLayout];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	
	CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);
	CGContextFillRect(ctx, CGRectMake(0, 0, self.frame.size.width, self.bounds.size.height/25.0));
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	[@"TASKS" drawInRect:CGRectMake(0, self.bounds.size.height/150.0, self.frame.size.width, self.bounds.size.height/25.0 - self.bounds.size.height/100.0) 
                withFont:[UIFont boldSystemFontOfSize:18] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	
	CGContextSetLineWidth(ctx,2);
	CGContextSetStrokeColorWithColor(ctx,  [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);
	CGContextStrokeRect(ctx, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
	[self setTransform:CGAffineTransformMakeRotation(rot)];
	
	
}

- (void) setRot:(float) newRot {
    rot = newRot;
}


- (void)layoutSubviews{
	int i =0;
	NSArray *sortedArray = [[self subviews] sortedArrayUsingSelector:@selector(compareByPointer:)];
	for(TaskView *subview in sortedArray){
		if(i<9){
				subview.frame=CGRectMake(10, 40+(60*i), (self.bounds.size.width)-20, 50);
				NSLog(@"Frame: %f",self.bounds.size.width);

			NSLog(@"Subview frame: %f",subview.bounds.size.width);
			
			
		}
		i++;
	}
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch ended on task container view");
    TaskView *newTask=[[TaskView alloc] initWithFrame:CGRectMake(10, 100, 230, 50) 
                                             withText: @"Ooo! I added a Task. Spiffeh"];
	if([[self subviews]count]<9){
		[self addSubview:newTask];
	}
    [self setNeedsLayout];
}

- (void)dealloc {
    [super dealloc];
}


@end