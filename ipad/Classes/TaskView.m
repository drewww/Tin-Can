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
		initialOrigin = CGPointMake(self.frame.origin.x, self.frame.origin.y);//self.frame.origin;  
		self.userInteractionEnabled = YES; 
		bgColor= [UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {

    // Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	
	CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);
	CGContextFillRect(ctx, CGRectMake(0, 0, 10, self.frame.size.height));
	CGContextSetFillColorWithColor(ctx, bgColor.CGColor);
	CGContextFillRect(ctx, CGRectMake(10, 0, self.frame.size.width-12, self.frame.size.height));
	CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:1 green:1 blue:1 alpha:.5].CGColor);
	[text drawInRect:CGRectMake(15, 2, self.frame.size.width-16, self.frame.size.height) 
			withFont:[UIFont systemFontOfSize:16] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
	
	CGContextSetLineWidth(ctx,2);
	CGContextSetStrokeColorWithColor(ctx,  [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);
	CGContextStrokeRect(ctx, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
	
	[self setNeedsDisplay];

}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"I have been touched");
	bgColor=[UIColor grayColor];
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
	
	//Calling setNeeds display undoes the rotation for some reason.
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	   NSLog(@"I have been touched but now I am not"); 

        [UIView beginAnimations:@"snap_to_initial_position" context:nil];
        
        [UIView setAnimationDuration:1.0f];
        
        CGRect newFrame = self.frame;
        newFrame.origin = CGPointMake(initialOrigin.x, initialOrigin.y);
        self.frame = newFrame;
        NSLog(@"animating to initialOrigin: %f, %f", initialOrigin.x, initialOrigin.y);
		[self.superview setNeedsLayout];
        [UIView commitAnimations];
		bgColor=[UIColor blackColor];
		[self setNeedsDisplay];
}


- (void)dealloc {
    [super dealloc];
}


@end
