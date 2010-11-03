//
//  TimelineContainerView.m
//  TinCan
//
//  Created by Drew Harry on 10/29/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "TimelineContainerView.h"
#import "EventView.h"

@implementation TimelineContainerView

#define COLOR [UIColor colorWithWhite:0.3 alpha:1]
#define PADDING 5
#define HEIGHT 25
#define HEADER_HEIGHT 22

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.frame=frame;
		
		[self setTransform:CGAffineTransformMakeRotation(M_PI/2)];

        // Get the recent timeline history. (Going to have to think about
        // how to get this at all.)
        
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(ctx, COLOR.CGColor);
	CGContextFillRect(ctx, CGRectMake(0, 0, self.bounds.size.width, HEADER_HEIGHT));
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	[@"TIMELINE" drawInRect:CGRectMake(0, 0, self.bounds.size.width, HEADER_HEIGHT) 
                       withFont:[UIFont boldSystemFontOfSize:18] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	
	CGContextSetLineWidth(ctx,2);
	CGContextSetStrokeColorWithColor(ctx,  COLOR.CGColor);
	CGContextStrokeRect(ctx, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
}


- (void)layoutSubviews{
	int i=0;

	NSArray *sortedArray = [[self subviews] sortedArrayUsingSelector:@selector(compareByTime:)];
    
    NSLog(@"sorted subview array: %@", sortedArray);
    
    // TODO
    // Since this is effectively a queue, when we draw, we'll want to look and see if
    // we have more EventViews that we're going to have space for. If we do, 
    // sort the and drop the ones farthest down the list (making sure to release them)
    
    // This is not the right layout, but we'll leave it that way for now until we 
    // actually figure out what EventViews will look like.
	for(EventView *subview in sortedArray){
//        subview.frame=CGRectMake(PADDING, HEADER_HEIGHT + PADDING+(HEIGHT*i) + (PADDING*(i)), self.frame.size.width-(PADDING*2), HEIGHT);
        subview.frame=CGRectMake(PADDING, HEADER_HEIGHT + PADDING+(HEIGHT*i) + (PADDING*(i)), self.frame.size.height-(PADDING*2), HEIGHT);
        
        i++;
	}
    
}

- (void)dealloc {
    [super dealloc];
}

@end
