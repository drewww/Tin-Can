//
//  LongDistanceCurrentTopicView.m
//  TinCan
//
//  Created by Drew Harry on 6/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "LongDistanceCurrentTopicView.h"
#import "StateManager.h"
#import "Topic.h"

// Shows the text of the current topic, as well as how long
// the topic has been going on for.

@implementation LongDistanceCurrentTopicView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 934, 279)];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();    
    
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    // Drawing code
    Topic *curTopic = [[StateManager sharedInstance].meeting getCurrentTopic];
    UIFont *font = [UIFont boldSystemFontOfSize:85];
    
    if(curTopic==nil) {
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.7 alpha:1.0].CGColor);
        [@"no current topic" drawInRect:CGRectMake(0, 0, 934, 209) withFont:font lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
        
    } else {
        
        [curTopic.text drawInRect:CGRectMake(0, 0, 934, 209) withFont:font lineBreakMode:UILineBreakModeTailTruncation];
        
        
        // figure out the duration
        UIFont *durationFont = [UIFont boldSystemFontOfSize:42];
        NSString *topicDurationString = [NSString stringWithFormat:@"for %.0fm", floor([curTopic.startTime timeIntervalSinceNow]*-1/60.0)];
        CGSize topicDurationSize = [topicDurationString sizeWithFont:durationFont];        
        [topicDurationString drawInRect:CGRectMake(934/2 - topicDurationSize.width/2, 209, topicDurationSize.width, topicDurationSize.height) withFont:durationFont];
    }
}


- (void)dealloc
{
    [super dealloc];
}

@end