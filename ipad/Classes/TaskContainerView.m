//
//  TaskContainerView.m
//  TinCan
//
//  Created by Paula Jacobs on 8/4/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "TaskContainerView.h"
#import "TaskView.h"

#define COLOR [UIColor colorWithWhite:0.3 alpha:1]

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

- (id)initWithFrame:(CGRect)frame withRot:(float)rotation {
    if ((self = [super initWithFrame:frame])) {
        
        self.frame=frame;
                
        rot = rotation;
		[self setTransform:CGAffineTransformMakeRotation(rot)];


		[self setNeedsLayout];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    UIColor *backgroundColor;
    if(hover) {
        backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    } else {
        backgroundColor = [UIColor blackColor];
    }
        

    CGContextSetFillColorWithColor(ctx, backgroundColor.CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));

    
	CGContextSetFillColorWithColor(ctx, COLOR.CGColor);
	CGContextFillRect(ctx, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height/22.0));
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	[@"TASKS" drawInRect:CGRectMake(0, self.bounds.size.height/150.0, self.bounds.size.width, self.bounds.size.height/25.0 - self.bounds.size.height/100.0) 
                withFont:[UIFont boldSystemFontOfSize:self.bounds.size.height/33.3] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];

	CGContextSetLineWidth(ctx,2);
	CGContextSetStrokeColorWithColor(ctx,  COLOR.CGColor);
	CGContextStrokeRect(ctx, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
    
		
	
}

- (void) setRot:(float) newRot {
    rot = newRot;
}


- (void)layoutSubviews{
	int i =0;
    NSLog(@"laying out task container with %d subviews", [[self subviews] count]);
	NSArray *sortedArray = [[self subviews] sortedArrayUsingSelector:@selector(compareByPointer:)];
	for(TaskView *subview in sortedArray){
		if([[self subviews]count]<=(floor(self.bounds.size.height/60.0))){
			NSLog(@"laying out task: %@", subview.task.text);
			subview.frame=CGRectMake(7, (self.bounds.size.height/22.0)+6.5 +(56.5*i), (self.bounds.size.width)-14, 50);
		}
		
		else {
			NSLog(@"laying out task: %@", subview.task.text);
			subview.frame=CGRectMake(7, (self.bounds.size.height/22.0)+6.5 +(28*i), (self.bounds.size.width)-14, (50-3)/2);
		}
		
		[subview setNeedsDisplay];
		NSLog(@"Frame: %f",self.bounds.size.width);

		NSLog(@"Subview frame: %f",subview.bounds.size.width);
		i++;
	}
	
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Used to create tasks programmatically here. Knocking that out now, since we're hooked up to the server.
}

- (void) setHoverState:(bool)state {
    hover = state;
    [self setNeedsDisplay];
}

- (void) setNeedsDisplay {
    [super setNeedsDisplay];
    
    for(UIView *v in self.subviews) {
        [v setNeedsDisplay];
    }
    
}

- (void)dealloc {
    [super dealloc];
}


@end