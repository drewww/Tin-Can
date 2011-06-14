//
//  LongDistanceRecentEventsView.m
//  TinCan
//
//  Created by Drew Harry on 6/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "LongDistanceRecentEventsView.h"

// Shows the most recent event (or two) that have happened
// in the meeting.
@implementation LongDistanceRecentEventsView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 934, 279)];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
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
