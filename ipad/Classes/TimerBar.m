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
		lengthOfSecond=0;
		
    }
    return self;
}
-(void)setLength{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponentsStart = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:startTime];
    NSInteger secondStart = [dateComponentsStart second]; 
	
	//current Time
    NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:testDate];
    NSInteger second = [dateComponents second];
	
    CGRectMake(0, 0, self.frame.size.width, self.frame.size.height); //We'll follow stephs model and divide up this space. 
	float diff=abs(secondStart-second);
	if (diff>=3600){
	lengthOfSecond= 300/ceil(diff/3600.0);
	}
	else{
		lengthOfSecond= 300/3600.0;
	}
	NSLog(@"diff:%f",diff);
	
}	
-(UIColor *)findNewColor{
	indexForColorWheel= indexForColorWheel +1;
	if (indexForColorWheel >= ([colorWheel count]-1)){
		indexForColorWheel=0;
	}
	return [colorWheel objectAtIndex:indexForColorWheel];
	
	
}	
	
//Creates a Time bar from an array of times
-(void)drawBarWithTimes:(NSMutableArray *)timelist withContext:(CGContextRef) ctx{
	int i =0;
	NSDate *tempEndTime;
	NSDate *tempStartTime;
	float elapsedTime;
	while (i< [timelist count]) {
		if (i==0){
		tempEndTime=[timelist objectAtIndex:i];
		tempStartTime=startTime;
		elapsedTime = abs([ tempStartTime  timeIntervalSinceDate:tempEndTime ]);
		CGContextSetFillColorWithColor(ctx,  [UIColor redColor].CGColor);
		CGContextFillRect(ctx, CGRectMake(0, 0, elapsedTime*lengthOfSecond, self.frame.size.height));
		lastPoint=	elapsedTime*lengthOfSecond;
		}//
//		else if (i==[timelist count]-1){
//			tempStartTime=[timelist objectAtIndex:i-1] ;
//			tempEndTime=[timelist objectAtIndex:i] ;
//			elapsedTime = abs([ tempStartTime  timeIntervalSinceDate:tempEndTime ]);
//			CGContextSetFillColorWithColor(ctx, [self findNewColor].CGColor);
//			CGContextFillRect(ctx, CGRectMake(lastPoint, 0, (elapsedTime*lengthOfSecond), self.frame.size.height));	
//
//			lastPoint=	elapsedTime*lengthOfSecond;
//		
//			
//		}
		else{
			tempStartTime=[timelist objectAtIndex:i-1] ;
			tempEndTime=[timelist objectAtIndex:i];
			elapsedTime = abs([ tempStartTime  timeIntervalSinceDate:tempEndTime ]);
			CGContextSetFillColorWithColor(ctx, [UIColor blueColor].CGColor);
			CGContextFillRect(ctx, CGRectMake(lastPoint, 0, (elapsedTime*lengthOfSecond), self.frame.size.height));	
			lastPoint=	lastPoint+ elapsedTime*lengthOfSecond;
		}
		i++;
		
		NSLog(@"elapsed time:%f",elapsedTime);
		NSLog(@"LastPoint:%f",lastPoint);
		
		NSLog(@"i:%d",i);
	}
	if(i==[timelist count]){
		CGContextSetFillColorWithColor(ctx, [self findNewColor].CGColor);
		elapsedTime= abs([ testDate  timeIntervalSinceDate:tempEndTime ]);
		CGContextFillRect(ctx, CGRectMake(lastPoint, 0, (elapsedTime*lengthOfSecond), self.frame.size.height));
	}
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	// for testing
	testDate= [[ testDate addTimeInterval:10] retain];
	[self setLength];
	//testDate= [[ testDate addTimeInterval:120] retain];
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	//CGContextSetFillColorWithColor(ctx, [UIColor blueColor].CGColor);
	//CGContextFillRect(ctx, CGRectMake(0,0, self.frame.size.width, self.frame.size.height));
	[self drawBarWithTimes:selectedTimes withContext:ctx];
		
	
}


- (void)dealloc {
    [super dealloc];
}


@end
