//
//  LocationView.m
//  TinCan
//
//  Created by Paula Jacobs on 8/13/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "LocationView.h"
#import "Location.h"

@implementation LocationView

@synthesize location;

- (id)initWithFrame:(CGRect)frame withLocation:(Location *)theLocation{
    if ((self = [super initWithFrame:frame])) {
        
        self.location = theLocation;
		self.frame=frame;
		self.alpha = 0;
		[UIView beginAnimations:@"fade_in" context:self];
		
		[UIView setAnimationDuration:.3f];
		
		self.alpha = 1.0;
		
		
		[UIView commitAnimations];
		
    }
    return self;
}

- (id) initWithLocation:(Location *)theLocation {
    
    return [self initWithFrame:CGRectMake(0, 0, 230, 25) withLocation:theLocation];
}

-(void)setFrameWidthWithContainerWidth:(CGFloat )width{
	self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, (width)-20, self.frame.size.height);
}

- (void)drawRect:(CGRect)rect {
	
    // Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(ctx, [UIColor blueColor].CGColor);
	CGContextFillRect(ctx, CGRectMake(0, 0, self.frame.size.height, self.frame.size.height));
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
		
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	
	
	CGSize statusSize = [[NSString stringWithFormat:@"%d",[location.users count]] sizeWithFont:[UIFont boldSystemFontOfSize:11]];
	
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);

	
	[[NSString stringWithFormat:@"%d",[location.users count]] drawInRect:CGRectMake((self.frame.size.height/2.0) -(statusSize.width/2.0), 7, self.frame.size.height, self.frame.size.height-5)
				 withFont:[UIFont boldSystemFontOfSize:11] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
	
	
	
	CGContextSetFillColorWithColor(ctx, [UIColor clearColor].CGColor);

	CGContextFillRect(ctx, CGRectMake(self.frame.size.height+1, 0, 137.5-(self.frame.size.height+1), self.frame.size.height));
	CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:1 green:1 blue:1 alpha:1].CGColor);
	[location.name drawInRect:CGRectMake(self.frame.size.height+3, 5,137.5-(self.frame.size.height+3), self.frame.size.height-4) 
			withFont:[UIFont boldSystemFontOfSize:14] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
	
	//CGContextSetLineWidth(ctx,2);
//	CGContextSetStrokeColorWithColor(ctx,  [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);
//	CGContextStrokeRect(ctx, CGRectMake(.5, .5, self.frame.size.width-1, self.frame.size.height-1));
	[self setNeedsDisplay];
	
	
}
- (NSComparisonResult) compareByPointer:(LocationView *)view {
    
    // Tries to comare by strings, but if they end up being exactly the same string,
    // it will resolve the ties by comparing pointers. This is a deterministic comparison
    // and an arbitrary (but stable) way to tell between tasks with identical text.
    // This is a rare case in real use, but happens a lot in testing, so this gives us some
    // protection from bad issues during demoing.
    NSComparisonResult retVal = [self.location.name compare:view.location.name];
    
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
