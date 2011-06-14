//
//  LongDistanceCurrentTopicView.m
//  TinCan
//
//  Created by Drew Harry on 6/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "LongDistanceCurrentTopicView.h"

// Shows the text of the current topic, as well as how long
// the topic has been going on for.

@implementation LongDistanceCurrentTopicView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 934, 279)];
    if (self) {
        self.backgroundColor = [UIColor greenColor];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc
{
    [super dealloc];
}

@end
