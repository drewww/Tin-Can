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
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    // need to wipe the background each time. Still have no idea why I have to do this sometimes
    // but not always.
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextFillRect(ctx, self.bounds);
    
    UIFont *f;
    CGSize size;
    if(topic==nil) {
        NSString *displayString = @"no current topic";
        f = [UIFont boldSystemFontOfSize:26];
        size = [displayString sizeWithFont:f];
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.7 alpha:1.0].CGColor);
//        [displayString drawInRect:CGRectMake(3, 3, self.bounds.size.width, self.bounds.size.height-25) withFont:f];
        [displayString drawAtPoint:CGPointMake(self.frame.size.height/2 - size.width/2, 30) withFont:f];
    } else {
        f = [UIFont boldSystemFontOfSize:18];
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:1.0 alpha:1.0].CGColor);
        [topic.text drawInRect:CGRectMake(3, 3, self.bounds.size.width, self.bounds.size.height-25) withFont:f];
        
        // Now add some extra metadata.
        NSString *topicAgeString = [NSString stringWithFormat:@"topic started %.0fm ago", floor([topic.startTime timeIntervalSinceNow]*-1/60.0)];
        [topicAgeString drawInRect:CGRectMake(3, self.bounds.size.height-25, self.bounds.size.width, 25) withFont:[UIFont systemFontOfSize:14]];
        
        NSString *createdByString = [NSString stringWithFormat:@"created by %@  ", topic.creator.name];
        [createdByString drawInRect:CGRectMake(3, self.bounds.size.height-25, self.bounds.size.width, 25) withFont:[UIFont systemFontOfSize:14]
                     lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
        
        
    }
}


- (void)dealloc {
    [super dealloc];
}


@end
