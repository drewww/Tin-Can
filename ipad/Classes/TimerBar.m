//
//  TimerBar.m
//  TinCan
//
//  Created by Paula Jacobs on 7/21/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "TimerBar.h"


@implementation TimerBar

- (id)initWithFrame:(CGRect)frame withStartTime:(NSDate *)time withEventTimes:(NSMutableArray *)times {
    if ((self = [super initWithFrame:frame])) {
		self.frame=frame;
        self.clearsContextBeforeDrawing = YES;
        startTime = [time retain];
		selectedTimes=times;
		elapsedSeconds=0.0;
		testDate= [[NSDate date] retain];
		colorWheel= [[NSMutableArray arrayWithObjects: [UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor cyanColor], 
					  [UIColor yellowColor], [UIColor magentaColor],[UIColor orangeColor],[UIColor purpleColor], nil] retain];
		indexForColorWheel=0;
		currentTimerColor=[colorWheel objectAtIndex: indexForColorWheel];
		lastPoint=0.0;
		timesToMarkHours=[[NSMutableArray array] retain];
		lengthOfSecond=0;
		differenceInTime=0;
		
    }
    return self;
}
-(void)setLength{
	CGFloat diff=abs([ startTime  timeIntervalSinceDate:testDate ]);
	//if (diff>=3600){
	lengthOfSecond= (300/ceil(diff/3600.0))/3600.0;
	differenceInTime=diff;
	//}
	//else{
	//	lengthOfSecond= 300/3600.0;
	//}
	NSLog(@"lengthOfSecond:%f",lengthOfSecond);
	NSLog(@"diff:%f",diff);
	
}	
-(UIColor *)findNewColor{
	indexForColorWheel= indexForColorWheel +1;
	if (indexForColorWheel >= ([colorWheel count]-1)){
		indexForColorWheel=0;
	}
	return [colorWheel objectAtIndex:indexForColorWheel];
	
	
}	
-(void)markHoursWithTimes:(NSMutableArray *)times withContext:(CGContextRef) ctx{
	for(NSNumber *time in times){
		float elapsedTime = abs([ startTime  timeIntervalSinceDate:time ]);
		CGContextSetFillColorWithColor(ctx,  [UIColor whiteColor].CGColor);
		CGContextFillRect(ctx, CGRectMake(lengthOfSecond*elapsedTime, 0, 5, self.frame.size.height));
	}
	
}
//Creates a Time bar from an array of times
-(void)drawBarWithTimes:(NSMutableArray *)timelist withContext:(CGContextRef) ctx{
	int i =0;
	NSDate *tempEndTime;
	NSDate *tempStartTime;
	float elapsedTime;
	CGContextSetFillColorWithColor(ctx,  [UIColor blackColor].CGColor);
	CGContextFillRect(ctx, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
	while (i<= [timelist count]) {
		if (i==0){
		tempEndTime=[timelist objectAtIndex:i];
		tempStartTime=startTime;
		elapsedTime = abs([ tempStartTime  timeIntervalSinceDate:tempEndTime ]);
		CGContextSetFillColorWithColor(ctx,  [UIColor redColor].CGColor);
		CGContextFillRect(ctx, CGRectMake(0, 0, elapsedTime*lengthOfSecond, self.frame.size.height));
		lastPoint=	elapsedTime*lengthOfSecond;
		}
		else if(i==[timelist count]){
			CGContextSetFillColorWithColor(ctx, [self findNewColor].CGColor);
			elapsedTime= abs([ testDate  timeIntervalSinceDate:tempEndTime ]);
			CGContextFillRect(ctx, CGRectMake(lastPoint, 0, (elapsedTime*lengthOfSecond), self.frame.size.height));
			
		}
		
		else{
			tempStartTime=[timelist objectAtIndex:i-1] ;
			tempEndTime=[timelist objectAtIndex:i];
			elapsedTime = abs([ tempStartTime  timeIntervalSinceDate:tempEndTime ]);
			CGContextSetFillColorWithColor(ctx, [UIColor blueColor].CGColor);
			CGContextFillRect(ctx, CGRectMake(lastPoint, 0, (elapsedTime*lengthOfSecond), self.frame.size.height));	
			lastPoint=	lastPoint+ elapsedTime*lengthOfSecond;
		}
		i++;
	}
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	// for testing
	testDate= [[ testDate addTimeInterval:60] retain];
	 
	
	
	[self setLength];
	[self setNeedsDisplay];
	
	[self drawBarWithTimes:selectedTimes withContext:ctx];
	
	
	int diff=(int)differenceInTime% 3600;
	//Maybe use time rather than point
	if(diff ==0){
		[timesToMarkHours addObject: testDate];
	}
	[self markHoursWithTimes:timesToMarkHours withContext:ctx];
	
	
	
}


- (void)dealloc {
    [super dealloc];
}


@end
