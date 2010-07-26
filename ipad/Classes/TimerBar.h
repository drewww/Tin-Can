//
//  TimerBar.h
//  TinCan
//
//  Created by Paula Jacobs on 7/21/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TimerBar : UIView {
	CGFloat initialRot;
    NSDate *startTime;
	NSDate *newDate;
	UIColor *currentTimerColor;
	NSMutableArray *selectedTimes;
	NSMutableArray *colorWheel;
	int indexForColorWheel;
	int elapsedSeconds;
	NSDate *testDate;
	CGFloat hourCounter;
	CGFloat timeToCompare;
	CGFloat lastPoint;
	CGFloat lengthOfSecond;
	CGFloat differenceInTime;
	NSMutableArray *timesToMarkHours;
	
}

- (id)initWithFrame:(CGRect)frame withStartTime:(NSDate *)time withEventTimes:(NSArray *)times;
-(UIColor *)findNewColor;
-(void)drawBarWithTimes:(NSMutableArray *)times withContext:(CGContextRef) context;
-(void)markHoursWithTimes:(NSMutableArray *)times withContext:(CGContextRef) ctx;
-(void)setLength;

@end
