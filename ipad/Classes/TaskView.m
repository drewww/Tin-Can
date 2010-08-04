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
		initialOrigin = self.frame.origin;
		self.userInteractionEnabled = YES; 
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
	[self setTransform:CGAffineTransformMakeRotation(M_PI/2)];

    // Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	
	CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);
	CGContextFillRect(ctx, CGRectMake(0, 0, self.frame.size.height-2, self.frame.size.width));
	CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
	CGContextFillRect(ctx, CGRectMake(10, 0, self.frame.size.height-12, self.frame.size.width));
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	[text drawInRect:CGRectMake(15, 2, self.frame.size.height-16, self.frame.size.width) 
			withFont:[UIFont systemFontOfSize:16] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
	//CGContextFillPath(ctx);
	CGContextSetLineWidth(ctx,2);
	CGContextSetStrokeColorWithColor(ctx,  [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);
	CGContextStrokeRect(ctx, CGRectMake(0, 0, self.frame.size.height, self.frame.size.width));
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"I have been touched");
    
	[self setNeedsDisplay];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"I have been moved and touched");
	// When we move, we want to know the delta from its previous location
	// and then we can adjust our position accordingly. 
	
	UITouch *touch = [touches anyObject];
	
	float dX = [touch locationInView:self.superview].x - [touch previousLocationInView:self.superview].x;
	float dY = [touch locationInView:self.superview].y - [touch previousLocationInView:self.superview].y;
	
	self.center = CGPointMake(self.center.x + dX, self.center.y + dY);
	
	
	[self setNeedsDisplay];
	[self bringSubviewToFront:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	   NSLog(@"I have been touched but now I am not"); 

        [UIView beginAnimations:@"snap_to_initial_position" context:nil];
        
        [UIView setAnimationDuration:1.0f];
        
        CGRect newFrame = self.frame;
        newFrame.origin = initialOrigin;
        self.frame = newFrame;
        NSLog(@"animating to initialOrigin: %f, %f", initialOrigin.x, initialOrigin.y);
		
        [UIView commitAnimations];
	
	[self setNeedsDisplay];
}


- (void)dealloc {
    [super dealloc];
}


@end
