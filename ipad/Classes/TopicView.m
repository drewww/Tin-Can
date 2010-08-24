//
//  TopicView.m
//  TinCan
//
//  Created by Paula Jacobs on 8/11/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "TopicView.h"
#import "Topic.h"

@implementation TopicView

@synthesize text;
@synthesize timeStart;
@synthesize timeFinished;
- (id)initWithFrame:(CGRect)frame withTopic:(Topic *)agenda{
    if ((self = [super initWithFrame:frame])) {
		self.frame=frame;
        topic=agenda;
		text=topic.text;
		//if([agenda.startTime isKindOfClass:[NSNull class]]){
		if(agenda.stopTime !=nil){
			timeFormat = [[[NSDateFormatter alloc] init] autorelease];
			[timeFormat setDateFormat:@"HH:mm:ss"];
			timeFinished=[[timeFormat stringFromDate:agenda.stopTime]retain];
			hasEnded=TRUE;
		}
		else{
			hasEnded=FALSE;
			timeFinished=nil;
		}
		
		if(agenda.startTime ==nil){
				timeStart=@"START";
		}
		else{
			timeFormat = [[[NSDateFormatter alloc] init] autorelease];
			[timeFormat setDateFormat:@"HH:mm:ss"];
			timeStart=[[timeFormat stringFromDate:agenda.startTime]retain];
			NSLog(@"Time:%@", agenda.startTime);
			NSLog(@"Time:%@",timeStart);
			
		}
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
	
    // Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
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
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);

	
	if(hasEnded==TRUE){
	[@"Started:" drawInRect:CGRectMake(3, 2, 45, self.frame.size.height-15)
					 withFont:[UIFont boldSystemFontOfSize:11] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
		
		
	[timeStart drawInRect:CGRectMake(3, 12, 45, self.frame.size.height-12)
					 withFont:[UIFont boldSystemFontOfSize:11] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
		
		
	CGContextSetFillColorWithColor(ctx, [UIColor redColor].CGColor);
	[@"Ended:" drawInRect:CGRectMake(3, 24, 45, self.frame.size.height-15)
						withFont:[UIFont boldSystemFontOfSize:11] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];

	[timeFinished drawInRect:CGRectMake(3, 36, 45, self.frame.size.height-15)
				 withFont:[UIFont boldSystemFontOfSize:11] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
	}
	else{
		if (![timeStart isEqualToString:@"START"]){
	[@"Started:" drawInRect:CGRectMake(3, 9, 45, self.frame.size.height-15)
					   withFont:[UIFont boldSystemFontOfSize:11] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
		
		
	[timeStart drawInRect:CGRectMake(3, 20, 45, self.frame.size.height-12)
					 withFont:[UIFont boldSystemFontOfSize:11] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
	}	
		else{
			[timeStart drawInRect:CGRectMake(5, 18, 45, self.frame.size.height-12)
						 withFont:[UIFont boldSystemFontOfSize:11] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
		}
		
	}
	CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
	CGContextFillRect(ctx, CGRectMake(50, 0, self.frame.size.width-50, self.frame.size.height));
	CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:1 green:1 blue:1 alpha:.5].CGColor);
	[text drawInRect:CGRectMake(54, 10, self.frame.size.width-54, self.frame.size.height-10) 
			withFont:[UIFont systemFontOfSize:16] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
	
	[self setNeedsDisplay];
	
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"I have been touched");
	isTouched=TRUE;
	if ([timeStart isEqualToString:@"START"]){
		timeFormat = [[[NSDateFormatter alloc] init] autorelease];
		[timeFormat setDateFormat:@"HH:mm:ss"];
		
		NSDate *now = [[[NSDate alloc] init] autorelease];
		
		
		timeStart = [[timeFormat stringFromDate:now] retain];
		
		
		NSLog(@"Time:%@",timeStart);
		NSLog(@"current date:%@",[NSDate date]);
//		[timeFormat release];
//		[now release];

	}
	else if(timeFinished ==nil){
		hasEnded=TRUE;
		timeFormat = [[[NSDateFormatter alloc] init] autorelease];
		[timeFormat setDateFormat:@"HH:mm:ss"];
		
		NSDate *now = [[[NSDate alloc] init] autorelease];
		
		
		timeFinished = [[timeFormat stringFromDate:now] retain];
	}	
	[self setNeedsDisplay];

	NSLog(@"leaving touches began");
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"I have been touched but now I am not"); 
	
	isTouched=FALSE;	
	[self setNeedsDisplay];
}

- (NSComparisonResult) compareByPointer:(TopicView *)view {
    
    // Tries to comare by strings, but if they end up being exactly the same string,
    // it will resolve the ties by comparing pointers. This is a deterministic comparison
    // and an arbitrary (but stable) way to tell between tasks with identical text.
    // This is a rare case in real use, but happens a lot in testing, so this gives us some
    // protection from bad issues during demoing.
   
	NSComparisonResult retVal = [self.timeStart compare:view.timeStart];
    
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
