//
//  CurrentTopicView.m
//  TinCan
//
//  Created by Drew Harry on 11/17/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "CurrentTopicView.h"
#import "UIColor+Util.h"


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
    
    UIFont *f;
    CGSize size;
    if(topic==nil) {
        self.backgroundColor = [UIColor clearColor];
        NSString *displayString = @"no current topic";
        f = [UIFont boldSystemFontOfSize:26];
        size = [displayString sizeWithFont:f];
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.7 alpha:1.0].CGColor);
//        [displayString drawInRect:CGRectMake(3, 3, self.bounds.size.width, self.bounds.size.height-25) withFont:f];
        [displayString drawAtPoint:CGPointMake(self.frame.size.height/2 - size.width/2, 30) withFont:f];
    } else {
        self.backgroundColor = [topic.color colorByChangingAlphaTo:0.3];
        
        f = [UIFont boldSystemFontOfSize:18];
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:1.0 alpha:1.0].CGColor);
        [topic.text drawInRect:CGRectMake(3, 3, self.bounds.size.width, self.bounds.size.height-25) withFont:f];
        
        // Now add some extra metadata.
        // We need to do a bit more work here to lay this out right - for long actor names for the creator,
        // we may need to use multiple lines.


        NSString *topicAgeString = [NSString stringWithFormat:@"topic started %.0fm ago", floor([topic.startTime timeIntervalSinceNow]*-1/60.0)];
        CGSize topicAgeSize = [topicAgeString sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(self.bounds.size.width/2, MAXFLOAT)];        
        [topicAgeString drawInRect:CGRectMake(3, self.bounds.size.height-topicAgeSize.height, self.bounds.size.width/2, topicAgeSize.height) withFont:[UIFont systemFontOfSize:14]];

        
        NSString *createdByString = [NSString stringWithFormat:@"created by %@  ", topic.creator.name];
        CGSize createdBySize = [createdByString sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(self.bounds.size.width/2, MAXFLOAT)];
        [createdByString drawInRect:CGRectMake(self.bounds.size.width/2, self.bounds.size.height-createdBySize.height, self.bounds.size.width/2, createdBySize.height) withFont:[UIFont systemFontOfSize:14]
                     lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
        
        
    }
}


- (void)dealloc {
    [super dealloc];
}


@end
