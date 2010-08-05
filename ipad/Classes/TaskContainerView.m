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


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {

        self.frame=frame;
		TaskView *firstTask=[[TaskView alloc] initWithFrame:CGRectMake(10, 40, 230, 50) 
												   withText: @"Leisure station ran out of pearls last night when I ordered."];
		TaskView *secondTask=[[TaskView alloc] initWithFrame:CGRectMake(10, 100, 230, 50) 
													withText: @"Alone with my music wearing socks on the tile, I dance."];
		TaskView *thirdTask=[[TaskView alloc] initWithFrame:CGRectMake(10, 160, 230, 50) 
												   withText: @"Stop Paula from writing silly stuff on the App."];
		TaskView *fourthTask=[[TaskView alloc] initWithFrame:CGRectMake(10, 220, 230, 50) 
													withText: @"Combs and brushes make the best microphones."];

		[self addSubview:firstTask];
		[self addSubview:secondTask];
		[self addSubview:thirdTask];
		[self addSubview:fourthTask];
		NSLog(@"subviews:%@",[self subviews]);
		[self setNeedsLayout];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	
	CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);
	CGContextFillRect(ctx, CGRectMake(0, 0, self.frame.size.width, 30));
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	[@"TASKS" drawInRect:CGRectMake(0, 5, self.frame.size.width, 20) 
			withFont:[UIFont boldSystemFontOfSize:18] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	
	CGContextSetLineWidth(ctx,2);
	CGContextSetStrokeColorWithColor(ctx,  [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);
	CGContextStrokeRect(ctx, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
	[self setTransform:CGAffineTransformMakeRotation(M_PI/2)];
	
	
}
- (void)layoutSubviews{
	int i =0;
	for(TaskView *subview in [self subviews]){
		if(i<9){
		subview.frame=CGRectMake(10, 40+(60*i), 230, 50);
		}
		else{
			break;
		}
		i++;
	}
		
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
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
