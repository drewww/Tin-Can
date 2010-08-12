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
- (id)initWithFrame:(CGRect)frame withTopic:(Topic *)agenda{
    if ((self = [super initWithFrame:frame])) {
		self.frame=frame;
        topic=agenda;
		text=topic.text;
		if(agenda.startTime==nil){
			timeStart=@"START";
		}
		else{
			timeFormat = [[NSDateFormatter alloc] init] ;
			[timeFormat setDateFormat:@"HH:mm:ss"];
			timeStart=[timeFormat stringFromDate:agenda.startTime];
		}
		self.userInteractionEnabled = YES; 
		isTouched= FALSE;
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame withText:(NSString *)words withStartTime:(NSDate *)date{ 
	if ((self = [super initWithFrame:frame])) {
		self.frame=frame;
        text=words;
		
		if(date==nil){
			timeStart=@"START";
		}
		else{
		timeFormat = [[NSDateFormatter alloc] init];
		[timeFormat setDateFormat:@"HH:mm:ss"];
		
		timeStart=[timeFormat stringFromDate:date];
		}
		self.userInteractionEnabled = YES; 
		isTouched= FALSE;
    }
    return self;
	
}

-(void)setFrameWidthWithContainerWidth:(CGFloat )width{
	self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, (width/2.0)-20, self.frame.size.height);
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

	
	[timeStart drawInRect:CGRectMake(3, 16, 45, self.frame.size.height-12)
			withFont:[UIFont boldSystemFontOfSize:11] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];

	
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
	if (timeStart==@"START"){
		timeFormat = [[[NSDateFormatter alloc] init] autorelease];
		[timeFormat setDateFormat:@"HH:mm:ss"];
		
		NSDate *now = [[[NSDate alloc] init] autorelease];
		
		
		timeStart = [[timeFormat stringFromDate:now] retain];
		
		
		
		NSLog(@"Time:%@",timeStart);
		NSLog(@"current date:%@",[NSDate date]);
//		[timeFormat release];
//		[now release];

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
    NSComparisonResult retVal = [self.text compare:view.text];
    
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
