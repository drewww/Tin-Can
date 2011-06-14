//
//  LongDistanceStatusBarView.m
//  TinCan
//
//  Created by Drew Harry on 6/14/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "LongDistanceStatusBarView.h"
#import "StateManager.h"

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
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    // This has three sections - a clock in the center, and two indicators on 
    // either side. We'll start by rendering the clock.
    
    // Make a string for the time.
    NSString *clockString = [formatter stringFromDate:curTime];
    
    UIFont *clockFont = [UIFont boldSystemFontOfSize:110];
    
    CGSize clockSize = [clockString sizeWithFont:clockFont];
    
    [clockString drawInRect:CGRectMake(934/2-clockSize.width/2, 120/2-clockSize.height/2, clockSize.width, clockSize.height) withFont:clockFont];
    
    // Pull the task/topic count from state.    
    NSString *numUnclaimedTasks = [NSString stringWithFormat:@"%d",[[[StateManager sharedInstance].meeting getUnassignedTasks] count],nil];
    
    NSString *numUpcomingTopics = [NSString stringWithFormat:@"%d",[[[StateManager sharedInstance].meeting getUpcomingTopics] count],nil];
    
    [numUnclaimedTasks drawInRect:CGRectMake(0, 0, 130, 120) withFont:clockFont];
    [numUpcomingTopics drawInRect:CGRectMake(934-130, 0, 130, 120) withFont:clockFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentRight];
    
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.7 alpha:1.0].CGColor);
    
    // Okay, now we need to handle the left and right side indicators. 
    NSString *unclaimedTasks = @"unclaimed tasks";
    NSString *upcomingTopics = @"upcoming topics";
    
    UIFont *labelFont = [UIFont boldSystemFontOfSize:36];
    
    [unclaimedTasks drawInRect:CGRectMake(130, 20, 200, 100) withFont:labelFont];
    [upcomingTopics drawInRect:CGRectMake(934-200-130, 20, 200, 100) withFont:labelFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentRight];
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
