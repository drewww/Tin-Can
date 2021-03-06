//
//  HeaderView.m
//  Login
//
//  Created by Paula Jacobs on 7/2/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "HeaderView.h"


@implementation HeaderView


- (id)initWithFrame:(CGRect)frame withTitle:(NSString *)title {
    if ((self = [super initWithFrame:frame])) {
		self.frame=frame;
		label=title;

    }
    return self;
}

//Creates our custom header
- (void)drawRect:(CGRect)rect {
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.37 green:.55 blue:.6 alpha:1].CGColor);
	CGContextFillRect(ctx, CGRectMake(0,0, self.frame.size.width, self.frame.size.height));
	CGFloat lineSize= self.frame.size.width/8.0;
	CGContextSetLineWidth(ctx, lineSize);
	CGContextSetShadow (ctx,CGSizeMake(0, 0) ,1);
	NSString *header = [@"" stringByAppendingString:label];
	
	
	[[UIColor whiteColor] set];
	[header drawInRect:self.bounds withFont:[UIFont boldSystemFontOfSize:50] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
	[self setTransform:CGAffineTransformMakeRotation(M_PI/2)];	
	[self setNeedsDisplay];
	
}

- (void)dealloc {
    [super dealloc];
}


@end
