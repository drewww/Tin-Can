//
//  LongDistanceView.m
//  TinCan
//
//  Created by Drew Harry on 6/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "LongDistanceView.h"



// This class is a container UIView that contains all the pieces that make up a
// LongDistanceView.

@implementation LongDistanceView

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 934, 678)];
    if (self) {

        self.backgroundColor = [UIColor blackColor];

        statusBar = [[[LongDistanceStatusBarView alloc] init] retain];
        topic = [[[LongDistanceCurrentTopicView alloc] init] retain];
        recentEvents = [[[LongDistanceRecentEventsView alloc] init] retain];
        
        // Each view places itself appropriate in its initWithFrame call.
        
        [self addSubview:statusBar];
        [self addSubview:topic];
        [self addSubview:recentEvents];
        
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        curRot = M_PI/2;
        
        [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(flipView:) userInfo:nil repeats:true];
    }
    return self;
}

- (void) clk {
    [statusBar clk];
    [topic setNeedsDisplay];
    [recentEvents setNeedsDisplay];
}

- (void) setNeedsDisplay {
//    [statusBar setNeedsDisplay];
//    [topic setNeedsDisplay];
//    [recentEvents setNeedsDisplay];
}

- (void) handleConnectionEvent:(Event *)event {
    [recentEvents newEvent:event];
}

- (void) flipView:(id)sender {
    [UIView animateWithDuration:1.0 animations:^{
        if(curRot > 0)
            curRot = -M_PI_2;
        else
            curRot = M_PI_2;
        
        self.transform = CGAffineTransformMakeRotation(curRot);
    }];
}

- (void)dealloc
{
    [statusBar release];
    [topic release];
    [recentEvents release];
    [super dealloc];
}

@end
