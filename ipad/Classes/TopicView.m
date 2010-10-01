//
//  TopicView.m
//  TinCan
//
//  Created by Paula Jacobs on 8/11/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "TopicView.h"
#import "Topic.h"
#import "ConnectionManager.h"

@implementation TopicView

@synthesize topic;

- (id)initWithFrame:(CGRect)frame withTopic:(Topic *)theTopic{
    if ((self = [super initWithFrame:frame])) {
		self.frame=frame;
        topic=theTopic;
        
		self.userInteractionEnabled = YES; 
		isTouched= FALSE;
		
		self.alpha = 0;
		[UIView beginAnimations:@"fade_in" context:self];
		
		[UIView setAnimationDuration:.3f];
		
		self.alpha = 1.0;
		
		
		[UIView commitAnimations];
    }
    return self;
}

- (id) initWithTopic:(Topic*)theTopic {
    
    // This is just a weak passthrough. Eventually, we'll knock out the initWithFrame
    // version and initWithTopic will be the only option. Leaving the old one for compatibility
    // reasons, because making tasks by hand on the client is a bit tedious for testing.
    
    return [self initWithFrame:CGRectMake(0, 0, 230, 50) withTopic:theTopic];
}


-(void)setFrameWidthWithContainerWidth:(CGFloat )width{
	self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, (width)-20, self.frame.size.height);
}

- (void)drawRect:(CGRect)rect {
    
    NSLog(@"------------------------TOPIC VIEW DRAW------------------");
    
    // Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
    
    // We're going to draw a little arc that represents the time this topic was talked about, if 
    // the topic has started or finished. If it hasn't started yet, we'll put a start button
    // there instead.
    
    if(topic.status == kPAST || topic.status == kCURRENT) {
        NSLog(@"Trying to draw the fancy thing.");
        // In this mode, we're basically going to steal the rendering code from the clock. We want to
        // make a little arc.  
        
        // First, figure out the rotation we need. That's based on the start time.
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:topic.startTime];
        NSInteger minute = [dateComponents minute];
        NSInteger second = [dateComponents second];
        [gregorian release];
        float rotation = ((minute*60 + second)/3600.0f) * (2*M_PI);
        
        CGContextSaveGState(ctx);
        // Enter into the rotated reference frame.
//        CGContextRotateCTM(ctx, rotation);
        CGContextMoveToPoint(ctx, 0, 0);
        
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);

        
        //lets draw our TIME ARC!
        NSDate *endTime;
        
        if(topic.stopTime != nil) {
            endTime = topic.stopTime;
        } else {
            endTime = [[NSDate date] autorelease];
        }
        
        float elapsedTime = abs([topic.startTime  timeIntervalSinceDate:endTime ]);

        
        CGFloat arcLength = elapsedTime/3600.0f * (2*M_PI);
        CGContextMoveToPoint(ctx, 25, 25);
        
//        CGContextAddEllipseInRect(ctx, CGRectMake(25, 25, 2, 2));
//        CGContextFillPath(ctx);
        
        NSLog(@"rotation: %f ; arcLength: %f", rotation, arcLength);
        
        //CGContextAddArc(ctx, 25, 25, 50, -M_PI/2 - arcLength, -M_PI/2 , 0); 
        CGContextMoveToPoint(ctx, 25, 25);
        CGContextAddArc(ctx, 25, 25, 25, rotation- M_PI/2, rotation + arcLength - M_PI/2, 0);
        CGContextFillPath(ctx);
        
        
//        CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
//        CGContextAddEllipseInRect(ctx, CGRectMake(25, 25, 35, 35));
//        CGContextFillPath(ctx);

        // now block out the middle chunk. 
        
        
        // Pop back to the normal non rotated reference frame.
        CGContextRestoreGState(ctx);
        
    } else {
        
        if(isTouched==FALSE){
            CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);
            CGContextFillRect(ctx, CGRectMake(0, 0, 50, self.frame.size.height));
            CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
            
        }
        else {
            CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:.4 green:.4 blue:.4 alpha:1].CGColor );
            CGContextFillRect(ctx, CGRectMake(0, 0, 50, self.frame.size.height));
            CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1].CGColor );
        }  
        
        // Now draw the start button.
        [@"START" drawInRect:CGRectMake(5, 18, 45, self.frame.size.height-12)
        	 withFont:[UIFont boldSystemFontOfSize:11] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
        
    }
    
    
	//if(isTouched==FALSE){
//		CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);
//		CGContextFillRect(ctx, CGRectMake(0, 0, 50, self.frame.size.height));
//		CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
//
//	}
//	else {
//		CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:.4 green:.4 blue:.4 alpha:1].CGColor );
//		CGContextFillRect(ctx, CGRectMake(0, 0, 50, self.frame.size.height));
//		CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:1].CGColor );
//
//
//	}
//	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
//	
//	if(topic.status == kPAST){
//	[@"Started:" drawInRect:CGRectMake(3, 2, 45, self.frame.size.height-15)
//					 withFont:[UIFont boldSystemFontOfSize:11] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
//		
//		
////	[timeStart drawInRect:CGRectMake(3, 12, 45, self.frame.size.height-12)
////					 withFont:[UIFont boldSystemFontOfSize:11] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
//		
//		
//	CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
//	[@"Ended:" drawInRect:CGRectMake(3, 24, 45, self.frame.size.height-15)
//						withFont:[UIFont boldSystemFontOfSize:11] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
//
////	[timeFinished drawInRect:CGRectMake(3, 36, 45, self.frame.size.height-15)
////				 withFont:[UIFont boldSystemFontOfSize:11] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
//	}
//	else if(topic.status == kCURRENT){
//	[@"Started:" drawInRect:CGRectMake(3, 9, 45, self.frame.size.height-15)
//					   withFont:[UIFont boldSystemFontOfSize:11] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
//		
//		
////	[timeStart drawInRect:CGRectMake(3, 20, 45, self.frame.size.height-12)
////					 withFont:[UIFont boldSystemFontOfSize:11] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
//	}	
//	else if(topic.status == kFUTURE){
//			[@"START" drawInRect:CGRectMake(5, 18, 45, self.frame.size.height-12)
//						 withFont:[UIFont boldSystemFontOfSize:11] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
//	}
//	CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
//	CGContextFillRect(ctx, CGRectMake(50, 0, self.frame.size.width-50, self.frame.size.height));
//    
    
    
    NSLog(@"topic text: %@", topic.text);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:1 green:1 blue:1 alpha:.5].CGColor);

	[topic.text drawInRect:CGRectMake(54, 10, self.frame.size.width-54, self.frame.size.height-10) 
			withFont:[UIFont systemFontOfSize:16] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
	
	[self setNeedsDisplay];
	
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	isTouched=TRUE;
	if (topic.status == kFUTURE){

        NSLog(@"Future item touched - end the current item and make this one current.");
        [[ConnectionManager sharedInstance] updateTopic:topic withStatus:kCURRENT];
        
	}
	else if(topic.status == kCURRENT){
        
        NSLog(@"Current item touched - end it.");
        [[ConnectionManager sharedInstance] updateTopic:topic withStatus:kPAST];
	}	
	[self setNeedsDisplay];

}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"I have been touched but now I am not"); 
	
	isTouched=FALSE;	
	[self.superview setNeedsDisplay];
	[self.superview setNeedsLayout];
}

- (NSComparisonResult) compareByState:(TopicView *)view {
    
    // Tries to comare by strings, but if they end up being exactly the same string,
    // it will resolve the ties by comparing pointers. This is a deterministic comparison
    // and an arbitrary (but stable) way to tell between tasks with identical text.
    // This is a rare case in real use, but happens a lot in testing, so this gives us some
    // protection from bad issues during demoing.
	
    NSComparisonResult retVal;
    if(topic.status < view.topic.status) {
        retVal = NSOrderedAscending;
    } else if (topic.status > view.topic.status) {
        retVal = NSOrderedDescending;
    }
    
	if(topic.status == view.topic.status) {
		if(topic.status == kPAST){
			retVal=[topic.startTime compare:view.topic.startTime];
		}
        // For future items, ordering doesn't matter (although we might order by creation time - or will there be some pre-meeting fixed ordering?)
        // For current items, there can be only one. Perhaps throw an error if we hit more than one in this process?
	}
	
    return retVal;
}
- (void)dealloc {
    [super dealloc];
}


@end
