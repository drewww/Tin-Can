//
//  TimerBar.h
//  TinCan
//
//  Created by Paula Jacobs on 7/21/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Meeting.h"

@interface TimerBar : UIView {
    Meeting *meeting;
	NSDate *curDate;
	
	int indexForColorWheel;
	NSMutableArray *colorWheel;
	int meetingDuration;

    NSMutableArray *timeBoundaries;
	CGFloat pixelsPerSecond;

    NSTimer *clock;

    CGFloat lastPoint;
}

- (id)initWithFrame:(CGRect)frame withMeeting:(Meeting *)theMeeting;

-(UIColor *)getNextColor;

-(void)drawBarWithTimes:(NSMutableArray *)times withContext:(CGContextRef) context;

-(void)setLength;
-(void)update;
- (void)clk;
@end
