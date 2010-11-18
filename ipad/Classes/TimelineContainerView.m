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
        
        eventContentView = [[EventContainerContentView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, self.bounds.size.width, self.bounds.size.height-HEADER_HEIGHT)];
        scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        
        [scrollView addSubview:eventContentView];
        [self addSubview:scrollView];
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


- (void) addEventView:(UIView *)eventView {
 
    [eventContentView addSubview:eventView];
    [eventContentView setNeedsLayout];
    
    [scrollView scrollRectToVisible:CGRectMake(0, 0, self.bounds.size.width, 50) animated:YES];
}

- (void) setNeedsLayout {
    [super setNeedsLayout];
    
    [eventContentView setNeedsLayout];
}

- (void)dealloc {
    [super dealloc];
}

@end
