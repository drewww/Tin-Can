//
//  TaskContainerView.m
//  TinCan
//
//  Created by Paula Jacobs on 8/4/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "TaskContainerView.h"
#import "TaskView.h"
#import "ConnectionManager.h"

#define COLOR [UIColor colorWithWhite:0.3 alpha:1]
#define BUTTON_COLOR [UIColor colorWithWhite:0.6 alpha:1]
#define BUTTON_PRESSED_COLOR [UIColor colorWithWhite:0.45 alpha:1]

#define HEADER_HEIGHT 26

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

- (id)initWithFrame:(CGRect)frame withRot:(float)rotation isMainView:(BOOL) mainView {
    if ((self = [super initWithFrame:frame])) {
        self.frame=frame;
                
        rot = rotation;
		[self setTransform:CGAffineTransformMakeRotation(rot)];

        isMainView = mainView;
        
        // Now setup the add topic popover.
        AddItemController *addTaskController = [[AddItemController alloc] initWithPlaceholder:@"new task" withButtonText:@"Add Task"];
        addTaskController.delegate = self;
        
        popoverController = [[UIPopoverController alloc] initWithContentViewController:addTaskController];
        
        [popoverController setPopoverContentSize:CGSizeMake(300, 100)];
        buttonPressed = NO;
        
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

    CGRect headerRect;
    CGRect headerLabelRect;
    
    double fontSize;
    
    if(isMainView) {
        // Used fixed size rects.
        headerRect = CGRectMake(0, 0, self.bounds.size.width, HEADER_HEIGHT);
        headerLabelRect = CGRectMake(0, 0, self.bounds.size.width, HEADER_HEIGHT-2);
        fontSize = 22;
        
    } else {
        // Use variable size rects.
        headerRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height/24.0);
        headerLabelRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height/25.0 - self.bounds.size.height/100.0); 
        fontSize = self.bounds.size.height/28.0;
    }
    
	CGContextSetFillColorWithColor(ctx, COLOR.CGColor);
	CGContextFillRect(ctx, headerRect);
    
    
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	[@"TASKS" drawInRect: headerLabelRect
                withFont:[UIFont boldSystemFontOfSize:fontSize] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];

	CGContextSetLineWidth(ctx,2);
	CGContextSetStrokeColorWithColor(ctx,  COLOR.CGColor);
	CGContextStrokeRect(ctx, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
    
 
    if(isMainView) {
        // Draw a + button in the header for adding tasks.
        if(buttonPressed) {
            CGContextSetFillColorWithColor(ctx, BUTTON_PRESSED_COLOR.CGColor);
        } else {
            CGContextSetFillColorWithColor(ctx, BUTTON_COLOR.CGColor);
        }
        
        buttonRect = CGRectMake(self.bounds.size.width-23, 3, 20, 20);
        
        CGContextFillRect(ctx, buttonRect);
        
        // Now put a plus in the middle of it. 
        CGContextSetFillColorWithColor(ctx, COLOR.CGColor);
        CGContextFillRect(ctx, CGRectInset(buttonRect, 9, 2));
        CGContextFillRect(ctx, CGRectInset(buttonRect, 2, 9));        
    }
    	
}

- (void) setRot:(float) newRot {
    rot = newRot;
}


- (void)layoutSubviews{
	int i =0;
    NSLog(@"laying out task container with %d subviews", [[self subviews] count]);
	NSArray *sortedArray = [[self subviews] sortedArrayUsingSelector:@selector(compareByPointer:)];
	for(TaskView *subview in sortedArray){
        
        // Make sure lastParentViews are up to date.
        subview.lastParentView = self;

        
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

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    CGPoint touchLoc = [touch locationInView:self];
    
    if(CGRectContainsPoint(buttonRect, touchLoc)) {
        buttonPressed = YES;
        [self setNeedsDisplay];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(buttonPressed) {
        // Trigger the add callback here.
        NSLog(@"Add button pressed! Do something now!");
        [popoverController presentPopoverFromRect:buttonRect inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
        
        buttonPressed = NO;
        [self setNeedsDisplay];
    }
}

- (void) itemSubmittedWithText:(NSString *)text {
    [popoverController dismissPopoverAnimated:YES];
    
    [[ConnectionManager sharedInstance] addTaskWithText:text];
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