//
//  MeetingTimerView.m
//  TinCan
//
//  Created by Drew Harry on 5/20/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "MeetingTimerView.h"
#import "StateManager.h"
#import "Topic.h"

@implementation MeetingTimerView

#define ROTATION_INDEX 0
#define TIME_INDEX 1
#define COLOR_INDEX 2
#define HOUR_INDEX 3
#define TYPE_INDEX 4

- (id)initWithFrame:(CGRect)frame withStartTime:(NSDate *)time{
    if ((self = [super initWithFrame:frame])) {
        
        // Set up the locations of the clock.
        self.bounds = CGRectMake(-165, -165, 326, 326);
        self.center = CGPointMake(384, 512);
        self.clearsContextBeforeDrawing = YES;
        
        
        // I have no idea what these are for. 
        hourCounter=0;
		timeToCompare=3600;
        initialRot = -1;
        elapsedSeconds=0.0;
		hourCheck=0;
        
        // Stores the boundaries between topics. This is going to get nuked and connected
        // back to the Topics list in the actual data model.
		selectedTimes=[[NSMutableArray array] retain];
		
        
        // This is the Current Time as far as the clock is concerned.
		curTime= [[NSDate date] retain];
        startTime = [time retain];
        
        
        // Color management. This is temporary until colors start coming from the server so all the
        // places that we render topics have unified coloring.
		colorWheel= [[NSMutableArray arrayWithObjects: [UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor cyanColor], 
					  [UIColor yellowColor], [UIColor magentaColor],[UIColor orangeColor],[UIColor purpleColor], nil] retain];
		indexForColorWheel=0;
		currentTimerColor=[colorWheel objectAtIndex: indexForColorWheel];
        
    }
    return self;
}



//calculates Rotation for things tracked by minutes (ie:minute hand)
-(CGFloat)getMinRotationWithDate:(NSDate *)date{
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
    NSInteger minute = [dateComponents minute];
    NSInteger second = [dateComponents second];
    [gregorian release];
	return ((minute*60 + second)/3600.0f) * (2*M_PI);
}


//calculates Rotation for hour hand
-(CGFloat)getHourRotationWithDate: (NSDate *)date{ 
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
    NSInteger hour = [dateComponents hour];
    NSInteger minute = [dateComponents minute];
    NSInteger second = [dateComponents second];
    [gregorian release];
	return  ((hour%12)*3600 + minute*60 + second)/(43200.0f) * (2*M_PI);
}




// Stores the important info to be used in the creation of a Time Arc
-(NSMutableArray *)storeNewTimeWithColor:(UIColor *)color withTime: (NSDate *)time withHour:(float) hour withType:(NSString *)type{
	
	NSDate *timeToSetTimeTo = time;
	CGFloat rotationOfTouchedTime= [self getMinRotationWithDate:timeToSetTimeTo];
	UIColor *colorToStore=color;
	float currentHour= hour;
	NSMutableArray *newlyStoredTime=[[NSMutableArray alloc] initWithCapacity:3];
	[newlyStoredTime addObject:[NSNumber numberWithFloat: rotationOfTouchedTime]];
	[newlyStoredTime addObject:timeToSetTimeTo];
	[newlyStoredTime addObject: colorToStore];
	[newlyStoredTime addObject: [NSNumber numberWithFloat:currentHour]];
	[newlyStoredTime addObject: type];
	return newlyStoredTime;
}


-  (NSMutableArray *)generateTimeBoundariesFromMeeting {
   // This function looks into the data model and from the topics there, generates
   // a data structure that can be used by the rendering side of this class.
   // In general, this is a pretty straightforward process: turn topic start points
   // into arc boundaries and pick an appropriate color for them. It's complicated,
   // though, by lack of very diligant tracking of topics - there will be gaps
   // between them, they won't start at the start of the meeting, etc.
   //
   // The other thing we have to watch out for is hour boundaries. Because of the 
   // way the rendering internals work, we need to do something special there
   // that I don't precisely understand yet. It probably involves just creating
   // extra boundaries on exactly the hour mark so no arc crosses the boundary.
    
   // First we need to sort the topics that come out of the meeting, since they're
   // in a set and not a list (because there are lots of ways one COULD sort them)
    
    NSMutableArray *boundaries = [NSMutableArray array];
    
    NSMutableArray *sortedTopics = [NSMutableArray arrayWithArray:[[StateManager sharedInstance].meeting.topics allObjects]];
    [sortedTopics sortUsingSelector:@selector(compareByStartTime:)];
    
    int colorIndex = 0;
    // Okay, now lets loop through these topics.
    bool topicOpen = true;
    int currentHour = 0;
    
    NSDate *curHourStart = [startTime copy];
    
    // First, insert a point at the beginning, so there's always something at time zero.
    NSMutableArray *startTimeBoundary = [NSMutableArray array];
    [startTimeBoundary addObject:[NSNumber numberWithFloat:[self getMinRotationWithDate:startTime]]];
    [startTimeBoundary addObject:startTime];
    
    // This shouldn't matter, right? Setting it to something annoying to see.
    [startTimeBoundary addObject:[UIColor purpleColor]];
    [startTimeBoundary addObject:[NSNumber numberWithInt:0]];
    [startTimeBoundary addObject:@"touch"];
    
    [boundaries addObject:startTimeBoundary];
    

    topicOpen = false;
    for (Topic *topic in sortedTopics) {
        // For each topic, we're going to add a boundary at the start and at the end.
        // Boundaries at the end are going to always have a gray color to show
        // inter-topic periods clearly.
        if(topic.startTime==nil) {
            NSLog(@"Found topic with no start time - skipping: %@", topic);
            continue;
        }

        NSLog(@"found a started topic: %@", topic);
        topicOpen = true;

        
        NSMutableArray *entry = [NSMutableArray array];
        [entry addObject:[NSNumber numberWithFloat:[self getMinRotationWithDate:topic.startTime]]];
        [entry addObject:topic.startTime];
        [entry addObject:[UIColor grayColor]];
        
        // This bit is for sure wrong, but we're going to just hard code for now to get the rest working.
        [entry addObject:[NSNumber numberWithInt:currentHour]];
        
        // This distinguishes between "touch" type boundaries (ie real changes in txxopic) and
        // "hour" boundaries which we insert on hour boundaries to make rendering possible.
        // I guess this is a useful distinction, but it's a bit of a clunky way to represent it.
        [entry addObject:@"touch"];
        
        [boundaries addObject:entry];
        
        
        
        // Okay, we need to detect hour boundaries between the start and the end times in this event.
        // All hours are measured relative to the startTime of the entire clock, so test if the seconds
        // since curHourStart is greater ethan 3600. If it is, then add a boundary at curHourStart+3600
        // and move curHourStart to that value. 
        NSDate *testTime;
        if(topic.stopTime !=nil) {
            testTime = topic.stopTime;
        } else {
            testTime = [NSDate date];
        }
        
        if([testTime timeIntervalSinceDate:curHourStart] > 3600) {
            NSLog(@"crossed the hour boundary!");
            
            curHourStart = [NSDate dateWithTimeIntervalSince1970:[curHourStart timeIntervalSince1970] + 3600];
            currentHour = currentHour+1;
            
            
            entry = [NSMutableArray array];
            [entry addObject:[NSNumber numberWithFloat:[self getMinRotationWithDate:curHourStart]]];
            [entry addObject:curHourStart];
            [entry addObject:[colorWheel objectAtIndex:colorIndex]];
            [entry addObject:[NSNumber numberWithInt:currentHour]];
            [entry addObject:@"Hour"];
            
            [boundaries addObject:entry];
        }
            
        
        
        entry = [NSMutableArray array];
        
        if(topic.stopTime != nil) {
            NSLog(@"Found topic with end time.");
            [entry addObject:[NSNumber numberWithFloat:[self getMinRotationWithDate:topic.stopTime]]];
            [entry addObject:topic.stopTime];
            [entry addObject:[colorWheel objectAtIndex:colorIndex]];
            [entry addObject:[NSNumber numberWithInt:currentHour]];
            [entry addObject:@"touch"];
            [boundaries addObject:entry];
            topicOpen = false;        
        
            colorIndex = colorIndex + 1;
            NSLog(@"colorIndex now: %d", colorIndex);
            if(colorIndex==[colorWheel count]) {
                NSLog(@"resetting color index");
                colorIndex = 0;
            }
        }
        
    }
    
    // Add a boundary for "now", which will force it to draw the last chunk with the right color.
    NSMutableArray *curTimeEntry = [NSMutableArray array];
    [curTimeEntry addObject:[NSNumber numberWithFloat:[self getMinRotationWithDate:[NSDate date]]]];
    [curTimeEntry addObject:[NSDate date]];
    
    // If topic open is true, it eans that there is a current topic that doesn't have 
    // an end time. If that's the case, then the last boundary we add should have the
    // color of the topic. If there is no current topic, the color should be gray. 
    NSLog(@"at end of loop, deciding how to color the growing section; topicOpen: %d", topicOpen);
    if(topicOpen) {
        [curTimeEntry addObject:[colorWheel objectAtIndex:colorIndex]];
    }
    else {
        [curTimeEntry addObject:[UIColor grayColor]];
    }

    [curTimeEntry addObject:[NSNumber numberWithFloat:hourCounter]];
    [curTimeEntry addObject:@"touch"];
    [boundaries addObject:curTimeEntry];
    
    
    NSLog(@"boundaries: %@", boundaries);
    return boundaries;
}


// Creates a Time Arc from an Array of Time Arc information and the current index
// This arc starts at the edge of the previous boundary and goes until the current
// boundary index. It takes its color from the current index, which means that
// colors propegate backwards, not forwards. There are also edge cases for the
// current time and when there are no boundaries, but I'm trying to squish those
// out by making automatic boundaries at those points. 
-(void)drawArcWithTimes:(NSMutableArray *)times withIndex:(int)boundaryIndex withContext:(CGContextRef) context{
    
	//Let's find out 'when' we are drawing
	NSDate *tempEndTime;
	NSDate *tempStartTime;
	CGContextRef ctx =context;
    
    // Shouldn't this be derivable from the actual time stamp involved?
	float currentHour=[[[times objectAtIndex:boundaryIndex] objectAtIndex:HOUR_INDEX]floatValue];
    
    // Set up the actual range we want to draw using just the deltas. If we're
    // on the first item, it starts at the start time. Otherwise, it's the difference
    // between the previous item and this item. 
	if (boundaryIndex==0){ 
		tempEndTime=[[times objectAtIndex:boundaryIndex] objectAtIndex:TIME_INDEX];
		tempStartTime=startTime;
		hourCheck=1;
	}
	else { 
		tempStartTime=[[times objectAtIndex:boundaryIndex-1] objectAtIndex:TIME_INDEX];
		tempEndTime=[[times objectAtIndex:boundaryIndex] objectAtIndex:TIME_INDEX];
	}
	
	// for creating black space
    // I think this happens when we're on the current hour, but not any previous hour (for multi-hour
    // displays only). Not 100% sure though.
	if ((currentHour==hourCounter)&&(hourCheck==1)){
		CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
		CGContextAddArc(ctx, 0, 0, 132-(hourCounter*10), 0, 2*M_PI , 0); 
		CGContextFillPath(ctx);
		hourCheck=0;
	}
    
    //On any drawing pass other than the first one...
	if (boundaryIndex!=0){
        
        
		float lastHour=[[[times objectAtIndex:boundaryIndex-1] objectAtIndex:HOUR_INDEX]floatValue];
		if (currentHour!=lastHour){
			CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
			CGContextAddArc(ctx, 0, 0, 132-(currentHour*10), 0, 2*M_PI , 0); 
			CGContextFillPath(ctx);
		}	
	}	
	//Let's set up 'where' we are drawing
	CGContextRotateCTM(ctx, [[[times objectAtIndex:boundaryIndex] objectAtIndex:ROTATION_INDEX]floatValue]);
	CGContextMoveToPoint(ctx, 0, 0);
	
	
	//lets draw our TIME ARC!
	float elapsedTime = abs([ tempStartTime  timeIntervalSinceDate:tempEndTime ]);
	CGFloat arcLength = elapsedTime/3600.0f * (2*M_PI);
	CGContextMoveToPoint(ctx, 0, 0);
	
	CGContextAddArc(ctx, 0, 0, 130-(currentHour*10), -M_PI/2 - arcLength, -M_PI/2 , 0); 
	
	
	// Let's Color!
	UIColor *colorRetrieved=[[times objectAtIndex:boundaryIndex] objectAtIndex:COLOR_INDEX];	
	CGContextSetFillColorWithColor(ctx, colorRetrieved.CGColor);
	CGContextFillPath(ctx);
	    
	// setting up blackspace on hour change
	if ((boundaryIndex==[times count]-1)&&([[times objectAtIndex:boundaryIndex] objectAtIndex:TYPE_INDEX]==@"Hour")){
		CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
		CGContextAddArc(ctx, 0, 0, 132-(hourCounter*10), 0, 2*M_PI , 0); 
		CGContextFillPath(ctx);
		hourCheck=0;
		//}
	}
	CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
	CGContextAddArc(ctx, 0, 0, 50, 0, 2*M_PI , 0); 
	CGContextFillPath(ctx);
	
}


- (void) clk {
    
    [curTime release];
    curTime = [[NSDate date] retain];
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
	
	NSMutableArray *boundaries = [self generateTimeBoundariesFromMeeting];
    
	// for testing
	// curTime= [[ curTime addTimeInterval:60] retain];
		
	// Drawing our Clock!
	
	
	
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
	//Let's set our Rotations early on.
	CGFloat hourRotation= [self getHourRotationWithDate:curTime];
	CGFloat minRotation= [self getMinRotationWithDate:curTime];
	
	
    //Wipe the layer manually because clearsContext doesn't work.
    CGContextSetRGBFillColor(ctx, 0, 0, 0, 1.0);
    CGContextFillRect(ctx, CGRectMake(-200, -200, 500, 500));
	
	
    // Puts it in landscape mode, basically - so the top of the clock is to the right in portrait mode
    CGContextRotateCTM(ctx, 0);
	
    // Draw the outline of the clock.
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1.0);
    CGContextSetLineWidth(ctx, 2.0);
    CGContextSaveGState(ctx);
    CGContextStrokeEllipseInRect(ctx, CGRectMake(-160, -155, 315, 315));
	
	
	
	
	
	//Drawing our past TIME ARCS!
	
	CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
	CGContextAddArc(ctx, 0, 0, 130-(hourCounter*5), 0, 2*M_PI , 0); 
	CGContextFillPath(ctx);
	
	
	
    // Do the bulk of the actual drawing here. Loop through each boundary marker
    // and draw an appropriate arc for that boundary.
	int i=0;
	while(i< [boundaries count]){
		[self drawArcWithTimes:boundaries withIndex:i  withContext:ctx];
		CGContextRestoreGState(ctx);
		CGContextSaveGState(ctx);
		i++;
	}
	
	
	//Drawing the Updating TIME ARC!
	
	//float rotation;	
//	if(initialRot==-1) {
//        // This was where the bug was. The initial rotation was coming from the CURRENT time when we first drew things. 
//        // This wasn't true once we split off startTime as a thing we could set in the constructor. Instead, we needed
//        // to re-calculate the rotation based on the startTime, not just reuse the minRotation. 
//		initialRot = [self getMinRotationWithDate:startTime];
//	}
//	//for the initial case where selectedTimes is empty:
//	//we want the updating TIME ARC to be between the start and now,
//	//starting with the intial Rotation
//	if([boundaries count] == 0) {
//		elapsedSeconds = abs([startTime timeIntervalSinceDate:curTime]);
//		
//		rotation = initialRot;
//	}
//	// Now that we are starting from the last TIMEARC,
//	// we can't use the intial rotation, so we use the stored rotation of 
//	// the last TIMEARC.
//	// elapsedSeconds is similarly updated.
//	else {
//		elapsedSeconds = abs([[[boundaries lastObject] objectAtIndex:TIME_INDEX] timeIntervalSinceDate:curTime]);
//		rotation = [[[boundaries lastObject] objectAtIndex:ROTATION_INDEX]floatValue];
//	}   
//	
//	// We want the updating TIME ARC to have the color of the next saved TIME ARC and the proper rotation
//    // Make sure to pull the color from the last boundary object so it matches.
//	CGContextRotateCTM(ctx, rotation);
//    
//    UIColor *currentArcColor;
//    if([boundaries count] > 0) 
//        currentArcColor = [[boundaries lastObject] objectAtIndex:COLOR_INDEX];
//    else {
//        currentArcColor = [UIColor grayColor];
//    }
//
//	CGContextSetFillColorWithColor(ctx, currentArcColor.CGColor);
//	CGContextMoveToPoint(ctx, 0.0, 0.0);
//	
//	// Now that we have elapsed seconds, lets draw our updating TIME ARC!
//	CGFloat arcLength = elapsedSeconds/3600.0f * (2*M_PI);
//	CGContextAddArc(ctx, 0, 0, 130-(hourCounter*10), -M_PI/2, -M_PI/2 + arcLength, 0);
//	CGContextAddLineToPoint(ctx, 0, 0);
//	CGContextFillPath(ctx);
//	CGContextRestoreGState(ctx);
//	CGContextSaveGState(ctx);
	
    // AFAICT this triggers on hour boundaries and is used to create new points to wrap around
    // the one hour mark. This is going to be a problem moving forward, because we don't want
    // to force the actual topic objects to break on hours. Perhaps we need a separate internal
    // representation afterall?
	if (timeToCompare <= abs([startTime timeIntervalSinceDate:curTime])) {
		
        NSLog(@"In the weird drawing if statement that also stores a new time. Why are we here?");
        
		timeToCompare= timeToCompare + 3600;
		indexForColorWheel= indexForColorWheel +1;
		
		if (indexForColorWheel >= ([colorWheel count]-1)){
			indexForColorWheel=0;
		}

		UIColor *colorToStore=currentTimerColor;
		
        // Creates a new boundary marker at the hour to make rendering easier.
        // We're going to need to fake this in the boundary generating thing. 
		//[selectedTimes addObject:[self storeNewTimeWithColor: colorToStore withTime:curTime withHour: hourCounter withType:@"Hour"]];
		hourCounter ++;
		
	}
	
	
	CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
	CGContextAddArc(ctx, 0, 0, 75, 0, 2*M_PI , 0); 
	CGContextFillPath(ctx);
	
	//Drawing Hour and Minute hand! (Drawn here so that the hands aren't colored over)
	CGContextRotateCTM(ctx, hourRotation);
	CGContextMoveToPoint(ctx, 0, 0);
	CGContextSetLineWidth(ctx, 1.0);
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
	CGContextAddRect (ctx, CGRectMake(-2.5, 0, 5, -90));
	CGContextFillPath(ctx);
	CGContextAddRect (ctx, CGRectMake(-2.5, 0, 5, -90));
	CGContextStrokePath(ctx);
	
	CGContextRestoreGState(ctx);
	CGContextSaveGState(ctx);	
	
	CGContextRotateCTM(ctx, minRotation);
	CGContextMoveToPoint(ctx, 0, 0);
	CGContextSetLineWidth(ctx, 1.0);
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
	CGContextAddRect (ctx, CGRectMake(-2.5, 0, 5, -130));
	CGContextFillPath(ctx);
	CGContextAddRect (ctx, CGRectMake(-2.5, 0, 5, -130));
	CGContextStrokePath(ctx);
	
	
	CGContextRestoreGState(ctx);
    
    // Now put numbers on the face of the clock
    NSString *twelve = @"12";
    NSString *six = @"6";
    NSString *three = @"3";
    NSString *nine = @"9";
    
    CGContextSetRGBFillColor(ctx, 1, 1, 1, 1.0);
    [twelve drawAtPoint:CGPointMake(-10, -153) withFont:[UIFont boldSystemFontOfSize:18]];
    [six drawAtPoint:CGPointMake(-10, 133) withFont:[UIFont boldSystemFontOfSize:18]];
    [three drawAtPoint:CGPointMake(135, -10) withFont:[UIFont boldSystemFontOfSize:18]];
    [nine drawAtPoint:CGPointMake(-145, -10) withFont:[UIFont boldSystemFontOfSize:18]];
	
	
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	CGContextAddArc(ctx, 0, 0, 4, 0, 2*M_PI , 0); 
	CGContextFillPath(ctx);
	
	CGAffineTransform transform=CGAffineTransformMakeScale(.75,.75);
	transform = CGAffineTransformRotate(transform, M_PI/2);
    [self setTransform:transform];  
	//[self setTransform:CGAffineTransformMakeScale(.75,.75)];
	//[self setTransform:CGAffineTransformMakeRotation(M_PI/2)];
}



-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	//Getting current index in color creation (for testing only)
	indexForColorWheel= indexForColorWheel +1;
	
	if (indexForColorWheel >= ([colorWheel count]-1)){
		indexForColorWheel=0;
	}
	//NSLog(@"index: %d", indexForColorWheel);
	UIColor *colorToStore=currentTimerColor;
	currentTimerColor= [colorWheel objectAtIndex: indexForColorWheel];
	
	//Stores important time info per touch
	//[selectedTimes addObject:[self storeNewTimeWithColor: colorToStore withTime:curTime withHour: hourCounter withType:@"Touch"]];	
}



- (void)dealloc {
	[currentTimerColor release];
    [startTime release];
	[selectedTimes release];
    [super dealloc];
	[UIColor release];
	[curTime release];
	
}


@end
