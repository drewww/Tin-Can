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
        self.backgroundColor = [UIColor clearColor];
        
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"H:mm"];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // This has three sections - a clock in the center, and two indicators on 
    // either side. We'll start by rendering the clock.
    
    // Make a string for the time.
    NSString *clockString = [formatter stringFromDate:curTime];
    
    UIFont *clockFont = [UIFont boldSystemFontOfSize:110];
    
    CGSize clockSize = [clockString sizeWithFont:clockFont];
    
    [clockString drawInRect:CGRectMake(934/2-clockSize.width/2, 120/2-clockSize.height/2, clockSize.width, clockSize.height) withFont:clockFont];
}

- (void) clk {
    [curTime release];
    curTime = [[NSDate date] retain];
    
    [self setNeedsDisplay];
}

- (void)dealloc
{
    [super dealloc];
}

@end
