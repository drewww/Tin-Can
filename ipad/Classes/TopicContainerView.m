//
//  TopicContainerView.m
//  TinCan
//
//  Created by Paula Jacobs on 8/11/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "TopicContainerView.h"
#import "TopicView.h"

@implementation TopicContainerView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.frame=frame;
		
        rot = M_PI/2;
		[self setTransform:CGAffineTransformMakeRotation(rot)];	
		
		[self setNeedsLayout];
		
    }
    
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);
	CGContextFillRect(ctx, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height/22.0));
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	[@"TOPICS" drawInRect:CGRectMake(0, self.bounds.size.height/150.0, self.bounds.size.width, self.bounds.size.height/25.0 - self.bounds.size.height/100.0) 
                withFont:[UIFont boldSystemFontOfSize:self.bounds.size.height/33.3] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	
	CGContextSetLineWidth(ctx,2);
	CGContextSetStrokeColorWithColor(ctx,  [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);
	CGContextStrokeRect(ctx, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
	
	
}

- (void) setRot:(float) newRot {
    rot = newRot;
}


- (void)layoutSubviews{
	int i =0;
	NSArray *sortedArray = [[self subviews] sortedArrayUsingSelector:@selector(compareByState:)];
	for(TopicView *subview in sortedArray){
		
		subview.frame=CGRectMake(7, (self.bounds.size.height/22.0)+6.5 +(56.5*i), (self.bounds.size.width)-14, 50);
		//NSLog(@"Frame: %f",self.bounds.size.width);
//		
//		NSLog(@"Subview frame: %f",subview.bounds.size.width);
		i++;
	}
    
}

- (void) setNeedsDisplay {
    [super setNeedsDisplay];
    
    for(UIView *v in self.subviews) {
        [v setNeedsDisplay];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch ended on task container view");
   
    [self setNeedsLayout];
    [self setNeedsDisplay];

}

- (void)dealloc {
    [super dealloc];
}


@end