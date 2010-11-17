//
//  CurrentTopicView.m
//  TinCan
//
//  Created by Drew Harry on 11/17/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "CurrentTopicView.h"


@implementation CurrentTopicView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        topic = nil;
                
		[self setTransform:CGAffineTransformMakeRotation(M_PI/2)];	

    }
    return self;
}

- (void)setTopic:(Topic *)newTopic {
    topic = newTopic;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    
    if(topic==nil) {
        NSString *displayString = @"no current topic";
        UIFont *f = [UIFont boldSystemFontOfSize:26];
        CGSize size = [displayString sizeWithFont:f];
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.7 alpha:1.0].CGColor);
        [displayString drawAtPoint:CGPointMake(self.frame.size.height/2 - size.width/2, 30) withFont:f];
    }
}


- (void)dealloc {
    [super dealloc];
}


@end
