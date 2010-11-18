//
//  TopicContainerView.m
//  TinCan
//
//  Created by Paula Jacobs on 8/11/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "TopicContainerView.h"
#import "TopicView.h"

#import "TopicContainerContentView.h"

@implementation TopicContainerView

#define COLOR [UIColor colorWithWhite:0.3 alpha:1]

#define HEADER_HEIGHT 26

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.frame=frame;
		
        rot = M_PI/2;
		[self setTransform:CGAffineTransformMakeRotation(rot)];	
        
        topicScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, self.bounds.size.width, self.bounds.size.height-HEADER_HEIGHT-2)];
        
        // The height on this one is just a placeholder - when it's layed out, it will calculate its own size.
        contentView = [[TopicContainerContentView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 50)];
        [contentView setNeedsLayout];
        
        [topicScrollView setCanCancelContentTouches:NO];
        topicScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;

        [topicScrollView addSubview:contentView];
        [self addSubview:topicScrollView];        
        
        
		[self setNeedsLayout];
    }
    
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(ctx, COLOR.CGColor);
	CGContextFillRect(ctx, CGRectMake(0, 0, self.bounds.size.width, HEADER_HEIGHT));
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	[@"TOPICS" drawInRect:CGRectMake(0, 1, self.bounds.size.width, HEADER_HEIGHT - 2) 
                withFont:[UIFont boldSystemFontOfSize:22] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	
	CGContextSetLineWidth(ctx,2);
	CGContextSetStrokeColorWithColor(ctx,  COLOR.CGColor);
	CGContextStrokeRect(ctx, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
	
	
}

- (void) setRot:(float) newRot {
    rot = newRot;
}

- (void) setNeedsDisplay {
    [super setNeedsDisplay];
    
    [contentView setNeedsDisplay];
}

- (void) setNeedsLayout {
    [super setNeedsLayout];
    
    [contentView setNeedsLayout];
    
}

- (void) addTopicView:(TopicView *)newTopicView {
    [contentView addSubview:newTopicView];
}

- (void)dealloc {
    [super dealloc];
    [contentView dealloc];
}


@end