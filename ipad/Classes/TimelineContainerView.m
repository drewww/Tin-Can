//
//  TimelineContainerView.m
//  TinCan
//
//  Created by Drew Harry on 10/29/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "TimelineContainerView.h"


@implementation TimelineContainerView


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
	CGContextFillRect(ctx, CGRectMake(0, 0, self.bounds.size.width, 22));
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	[@"TIMELINE" drawInRect:CGRectMake(0, 0, self.bounds.size.width, 22) 
                       withFont:[UIFont boldSystemFontOfSize:18] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	
	CGContextSetLineWidth(ctx,2);
	CGContextSetStrokeColorWithColor(ctx,  COLOR.CGColor);
	CGContextStrokeRect(ctx, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
}


// Turn this on when we actually have subviews.
//- (void)layoutSubviews{
//	int i=0;
//	int c=0;
//	NSArray *sortedArray = [[self subviews] sortedArrayUsingSelector:@selector(compareByPointer:)];
//	for(TimelineView *subview in sortedArray){
//		if ( i < 3 ) {
//			subview.frame=CGRectMake(5, 27 +(33.25*i), 137.5 , 28.25);
//            
//		}
//		else{
//			subview.frame=CGRectMake(147.5, 27 +(33.25*c), 137.5, 28.25);
//			c++;
//		}
//        
//		i++;
//	}
//    
//}


- (void)dealloc {
    [super dealloc];
}


@end
