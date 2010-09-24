//
//  TaskView.m
//  TinCan
//
//  Created by Paula Jacobs on 8/3/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "TaskView.h"
#import "Task.h"
#import "DragManager.h"

@implementation TaskView

@synthesize task;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame withTask:(Task *)theTask{
    if ((self = [super initWithFrame:frame])) {
		self.frame=frame;

		task = theTask;
        
        initialOrigin = CGPointMake(self.frame.origin.x, self.frame.origin.y);//self.frame.origin;  
		self.userInteractionEnabled = YES; 
		isTouched= FALSE;
		
        // Set our own delegate on init.
        self.delegate = [DragManager sharedInstance];
        
		self.alpha = 0;
		[UIView beginAnimations:@"fade_in" context:self];
		
		[UIView setAnimationDuration:.3f];
				
		self.alpha = 1.0;
		
		
		[UIView commitAnimations];
		
    }
    return self;
}

- (id) initWithTask:(Task *)theTask {
    return [self initWithFrame:CGRectMake(0, 0, 230, 50) withTask:theTask];
}

-(void)setFrameWidthWithContainerWidth:(CGFloat )width{
	self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, (width)-20, self.frame.size.height);
}

- (void)drawRect:(CGRect)rect {

    // Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	
	CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);
	CGContextFillRect(ctx, CGRectMake(0, 0, 10, self.frame.size.height));
	if(isTouched==FALSE){
	CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
	}
	else {
		CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1].CGColor );
	}

	CGContextFillRect(ctx, CGRectMake(10, 0, self.frame.size.width-12, self.frame.size.height));
	CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:1 green:1 blue:1 alpha:.5].CGColor);
	[task.text drawInRect:CGRectMake(15, 2, self.frame.size.width-16, self.frame.size.height) 
			withFont:[UIFont systemFontOfSize:16] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
	
	CGContextSetLineWidth(ctx,2);
	CGContextSetStrokeColorWithColor(ctx,  [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);
	CGContextStrokeRect(ctx, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
	
	[self setNeedsDisplay];

}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"I have been touched");
	isTouched=TRUE;
	//self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width-100, 50);
	[self setNeedsDisplay];
	[self.superview bringSubviewToFront:self];
   
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

    
    // Inform the delegate.
    [self.delegate taskDragMovedWithTouch:touch withEvent:event withTask:self.task];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    // TODO think about multitouch for this!
    UITouch *touch = [touches anyObject];
    
    if (![self.delegate taskDragEndedWithTouch:touch withEvent:event withTask:self.task]) {
        //
        
        [UIView beginAnimations:@"snap_to_initial_position" context:nil];
        
        [UIView setAnimationDuration:1.0f];
        
        CGRect newFrame = self.frame;
        newFrame.origin = CGPointMake(initialOrigin.x, initialOrigin.y);
        self.frame = newFrame;
        NSLog(@"animating to initialOrigin: %f, %f", initialOrigin.x, initialOrigin.y);
		[self.superview setNeedsLayout];
        [UIView commitAnimations];
		isTouched=FALSE;
		[self.superview sendSubviewToBack:self];
    } else {
            // We were dropped on an actual drop target. Something else will handle our
            // animation at this point (although we should think about moving it here for
            // consistency.
    }
    

		[self setNeedsDisplay];
}

- (NSComparisonResult) compareByPointer:(TaskView *)view {
    
    // Tries to comare by strings, but if they end up being exactly the same string,
    // it will resolve the ties by comparing pointers. This is a deterministic comparison
    // and an arbitrary (but stable) way to tell between tasks with identical text.
    // This is a rare case in real use, but happens a lot in testing, so this gives us some
    // protection from bad issues during demoing.
        
    NSComparisonResult retVal = [self.task.text compare:view.task.text];
    
    if(retVal==NSOrderedSame) {
        if (self < view)
            retVal = NSOrderedAscending;
        else if (self > view) 
            retVal = NSOrderedDescending;
    }
    
    return retVal;
}

- (void)dealloc {
    [super dealloc];
}


@end
