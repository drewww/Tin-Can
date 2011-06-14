//
//  LongDistanceStatusBarView.m
//  TinCan
//
//  Created by Drew Harry on 6/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "LongDistanceStatusBarView.h"

// The status bar that sits in the middle of the long distance view
// and shows the current time, number of upcoming topics, and 
// number of unclaimed tasks.
@implementation LongDistanceStatusBarView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 279, 934, 120)];
    if (self) {
        self.backgroundColor = [UIColor redColor];
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
