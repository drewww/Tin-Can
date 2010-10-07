//
//  TimerBar.m
//  TinCan
//
//  Created by Paula Jacobs on 7/21/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "TimerBar.h"
#import "Meeting.h"
#import "Topic.h"

@implementation TimerBar

- (id)initWithFrame:(CGRect)frame withMeeting:(Meeting *)theMeeting {
    if ((self = [super initWithFrame:frame])) {
		self.frame=frame;
        self.clearsContextBeforeDrawing = YES;

        meeting = theMeeting;
        
		curDate= [[NSDate date] retain];

		indexForColorWheel=0;
		colorWheel = [[NSMutableArray arrayWithObjects:[UIColor colorWithWhite:0.6 alpha:1.0], [UIColor colorWithWhite:0.4 alpha:1.0], nil] retain];
        
        
		clock = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(clk) userInfo:nil repeats:YES];
		[clock retain]; 
    }
    return self;
}
-(void)setLength{
	CGFloat diff=abs([meeting.startedAt  timeIntervalSinceDate:curDate ]);
    
    // The ceil function here manages to decrease in scale once we cross hour boundaries.
	pixelsPerSecond= (300/ceil(diff/3600.0))/3600.0;
	meetingDuration =diff;
	
}	
-(UIColor *)getNextColor{
	indexForColorWheel= indexForColorWheel +1;
	if (indexForColorWheel == ([colorWheel count])){
		indexForColorWheel=0;
	}
    NSLog(@"about to get color at %d", indexForColorWheel);
	return [colorWheel objectAtIndex:indexForColorWheel];
}

- (void)clk {
    [self update];
	[self setNeedsDisplay];
} 

//Creates a Time bar from an array of times
-(void)drawBarWithTimes:(NSMutableArray *)boundariesList withContext:(CGContextRef) ctx{
	int i =0;
	NSDate *tempEndTime;
	NSDate *tempStartTime;
	float elapsedTime;
    
    // Change how colors are selected so they're just alternating grays, like
    // on the latest version of the clock. This saves our weird oscilllating issue,
    // and avoids (for now) the problem of picking colors for topics on the server
    // (although we're going to have to do that eventually, I suspect)
    
    
	CGContextFillRect(ctx, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
	while (i< [boundariesList count]) {
        NSLog(@"rendering boundry %d: %@", i, [boundariesList objectAtIndex:i]);
		if (i==0){
            // For the first entry, start at the meeting start time and go to the 
            // first item in the boundariesList (which is the start of the first topic.
            // This is effectively "dead" time, so color it appropriately. 
            tempEndTime=[boundariesList objectAtIndex:i];
            tempStartTime=meeting.startedAt;
            elapsedTime = abs([ tempStartTime  timeIntervalSinceDate:tempEndTime ]);
            CGContextSetFillColorWithColor(ctx,  [UIColor colorWithWhite:0.3 alpha:1.0].CGColor);
            CGContextFillRect(ctx, CGRectMake(0, 0, elapsedTime*pixelsPerSecond, self.frame.size.height));
            lastPoint =	elapsedTime*pixelsPerSecond;
		} else {
            // This is the normal situation - rending every zone except the first/last.
			tempStartTime=[boundariesList objectAtIndex:i-1] ;
			tempEndTime=[boundariesList objectAtIndex:i];
            
			elapsedTime = abs([tempStartTime  timeIntervalSinceDate:tempEndTime ]);
            
            if(elapsedTime < 1) {
                i++;
                continue;
            }
            
			CGContextSetFillColorWithColor(ctx, [self getNextColor].CGColor);
			CGContextFillRect(ctx, CGRectMake(lastPoint, 0, (elapsedTime*pixelsPerSecond), self.frame.size.height));	
            lastPoint = elapsedTime*pixelsPerSecond;
		}
		i++;
	}
}
-(void) update{
    // Normal speed time.
    [curDate release];
	curDate= [[NSDate date] retain];


    
    // Generate the current set of times from the meeting object. 
    // This is a bit time consuming, but easier than updating on events
    // for now. 
    NSMutableArray *newTimeBoundaries = [NSMutableArray array];
    NSLog(@"generating boundaries");
    
    // Make sure the topics are sorted properly first.
    
    NSMutableArray *sortedTopics = [NSMutableArray arrayWithArray:[meeting.topics allObjects]];
    [sortedTopics sortUsingSelector:@selector(compareByStartTime:)];

    
    for(Topic *topic in sortedTopics) {
        if(topic.startTime != nil) {
            [newTimeBoundaries addObject:topic.startTime];
            
            
            if(topic.stopTime != nil) {
                [newTimeBoundaries addObject:topic.stopTime];   
            } else {
                // If there's a start time but no stop time,
                // then it's a currently open topic and we should
                // add the current time stamp as a boundary.
                [newTimeBoundaries addObject:[NSDate date]];
            }
            
         }
    }
    
    [timeBoundaries release];
    timeBoundaries = [newTimeBoundaries retain];
    
    NSLog(@"Time boundaries: %@", timeBoundaries);
}
	
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();

    // Make sure to reset this, otherwise it accumulates state across drawing runs
    // and causes weird issues with colors oscillating.
    indexForColorWheel = 0;
	
    // Make the background super light gray.
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.88 alpha:1.0].CGColor);
    CGContextFillRect(ctx, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
    
	[self setLength];
	
	[self drawBarWithTimes:timeBoundaries withContext:ctx];
	    
    // Handle the hour markers (not using the internal method anymore)
    int numHours = floor(abs([curDate timeIntervalSinceDate:meeting.startedAt])/3600.0);
    
    // For each hour, go an hour in and draw a white box.
    // Slightly wacky for loop for loop since we're not drawing
    // a box at the starting point, only at the subsequent
    // hour markers.
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    for(int i=1; i<=numHours; i++) {
        
        int hourPoint = i*3600*pixelsPerSecond;
        
        CGContextFillRect(ctx, CGRectMake(hourPoint - 1, 0, 2, self.frame.size.height));
    }
}


- (void)dealloc {
    [super dealloc];
    [clock release];
    [colorWheel release];
}


@end
