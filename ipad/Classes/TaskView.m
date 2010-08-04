//
//  TaskView.m
//  TinCan
//
//  Created by Paula Jacobs on 8/3/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "TaskView.h"


@implementation TaskView


- (id)initWithFrame:(CGRect)frame withText:(NSString *)task{
    if ((self = [super initWithFrame:frame])) {
		self.frame=frame;
        text=task;
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	
	CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
	CGContextFillRect(ctx, CGRectMake(0, 0, self.frame.size.width-2, self.frame.size.height-2));
	CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
	CGContextFillRect(ctx, CGRectMake(20, 0, self.frame.size.width-22, self.frame.size.height-2));
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	[text drawInRect:CGRectMake(22, 0, self.frame.size.width-24, self.frame.size.height-2) 
			withFont:[UIFont systemFontOfSize:12] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
	//CGContextFillPath(ctx);
	CGContextSetLineWidth(ctx,2);
	CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
	CGContextStrokeRect(ctx, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
}

- (void)dealloc {
    [super dealloc];
}


@end
