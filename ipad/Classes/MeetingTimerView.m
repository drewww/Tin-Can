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

#define TOPIC_OUTER_RADIUS 130
#define HOUR_BAND_WIDTH 15
#define HOUR_MARGIN_WIDTH 3

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
        
        emptyTimeColor = [[UIColor colorWithWhite:0.2 alpha:1.0] retain];
        
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

- (void) clk {
    [curTime release];
    curTime = [[NSDate date] retain];
//    curTime = [[curTime addTimeInterval:100] retain];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	
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
	
    // Here is where we draw the topics.
    // First, we want to loop through all the topics.
    NSMutableArray *sortedTopics = [NSMutableArray arrayWithArray:[[StateManager sharedInstance].meeting.topics allObjects]];
    [sortedTopics sortUsingSelector:@selector(compareByStartTime:)];
    
    // Loop through each topic.
    int curHour = 0;
    NSDate *curHourStart = nil;
    NSDate *tmpStartTime;
    NSDate *tmpStopTime;
    NSDate *curHourStop;

    for(Topic *topic in sortedTopics) {
        CGContextSaveGState(ctx);        
        if(topic.status==kFUTURE) {
            NSLog(@"Hit a future item, stopping. (these should be sorted to the end)");
            break;
        }
        
        // Grab the start time of the first topic, and make that our current hour start.
        if(curHourStart == nil) {
            curHourStart = topic.startTime;
            NSLog(@"setting cur hour start: %@", curHourStart);
        }
        
        // Rotate into position, so we can always draw straight up.
        
        
        
        
        // This tmp start time stores an updateable start time, so when we're drawing
        // from hour boundaries it'll still work properly.
        tmpStartTime = topic.startTime;
        
        if(topic.status==kPAST) {
            tmpStopTime = topic.stopTime;
        } else {
            tmpStopTime = curTime;
        }

        // Using tmpStart and tmpStop makes it easier to deal with two issues:
        // the current topic which extends as the clock hand moves (ie it has
        // no stop point) and the situation when we need to finish a topic's
        // space up to the end of the hour but not beyond it. 
        float elapsedTime;

        // Look for cases in which the current topic extends beyond the hour boundary.
        while(abs([curHourStart timeIntervalSinceDate:tmpStopTime]) > 3600) {
            
            NSLog(@"PAST THE HOUR BOUNDARY");
            
            
            curHourStop = [[NSDate dateWithTimeIntervalSince1970:[curHourStart timeIntervalSince1970] + 3600] retain];
            
            // At this point, we want to make an arc that goes from startTime to now, and then
            // fake the next drawing chunk into thinking its going from curHourTime to 
            // stopTime. This closes out the hour. If it's a multi-hour topic, then
            // the while loop will catch it and notice that we're STILL ending more than
            // an hour from the tmpStartTime (which at that point will be the last hour
            // boundary) and do this whole process again. Finally, the arc drawing
            // code outside the loop will cap it off and draw the part of the arc that goes
            // from the end of the most recent hour to the current time.
            
            // draw the arc from the temporary time (which on the first pass will be the 
            // start time, and on subsequent loops will be the previous hour's stop time)
            // to the current hour's stop time.
            
            // Do this in a separate rotation context, because it's at a different position than
            // the position of the arc that will follow it up.
            CGContextSaveGState(ctx);
            CGContextRotateCTM(ctx, [self getMinRotationWithDate:tmpStartTime]-M_PI/2);
            CGContextMoveToPoint(ctx, 0, 0);
            
            elapsedTime = abs([tmpStartTime  timeIntervalSinceDate:curHourStop]);
            CGFloat arcLength = elapsedTime/3600.0f * (2*M_PI);
            CGContextMoveToPoint(ctx, 0, 0);
            
            CGContextAddArc(ctx, 0, 0, TOPIC_OUTER_RADIUS-(HOUR_BAND_WIDTH + HOUR_MARGIN_WIDTH)*curHour, 0, arcLength, 0); 
            
            CGContextRestoreGState(ctx);
            
            // Set the color and fill the path. 
            CGContextSetFillColorWithColor(ctx, topic.color.CGColor);
            CGContextFillPath(ctx);            
            
            // at the end, update the tempStartTime to be the beginning of the hour so when we draw
            // in the next loop OR in the final drawing procedure
            curHourStart = curHourStop;
            tmpStartTime = curHourStart;


            // Fill in the circle to get a small black border between the bands.
            CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
            float radius = TOPIC_OUTER_RADIUS-HOUR_BAND_WIDTH*(curHour+1) - HOUR_MARGIN_WIDTH*(curHour);
            CGContextFillEllipseInRect(ctx, CGRectMake(-radius, -radius, 2*radius, 2*radius));
            
            // Now increment the hour counter.
            curHour = curHour+1;
        }
        
        // For normal topics that don't cross hour boundaries, draw the whole topic here.
        // For topics that DO cross hour boundaries, just draw the last bit that goes
        // from the end of the most recent hour to the end time of this topic.
        CGContextRotateCTM(ctx, [self getMinRotationWithDate:tmpStartTime]-M_PI/2);
        CGContextMoveToPoint(ctx, 0, 0);

        // If it's a past item, then we know it'll have a stop time. Otherwise, the stop time is
        // now. (this will be slightly different when we have a non-topic as the current topic
        // that needs to grow, but we'll handle that later. for now, non-topics just won't show
        // up at all, which is basically fine.)
        elapsedTime = abs([tmpStartTime  timeIntervalSinceDate:tmpStopTime]);
        
        CGFloat arcLength = elapsedTime/3600.0f * (2*M_PI);
        CGContextMoveToPoint(ctx, 0, 0);
        
        CGContextAddArc(ctx, 0, 0, TOPIC_OUTER_RADIUS-(HOUR_BAND_WIDTH + HOUR_MARGIN_WIDTH)*curHour, 0, arcLength, 0); 
        
        // Set the color and fill the path. 
        CGContextSetFillColorWithColor(ctx, topic.color.CGColor);
        CGContextFillPath(ctx);
        CGContextRestoreGState(ctx);
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


- (void)dealloc {
	[currentTimerColor release];
    [startTime release];
	[selectedTimes release];
    [super dealloc];
	[UIColor release];
	[curTime release];
	
}


@end
