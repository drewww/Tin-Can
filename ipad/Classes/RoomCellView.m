//
//  RoomCellView.m
//  Login
//
//  Created by Paula Jacobs on 6/30/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "RoomCellView.h"
#import "TimerBar.h"
#import "Meeting.h"
#import "Room.h"

@implementation RoomCellView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        self.opaque = YES;
        self.backgroundColor = [UIColor clearColor];
		
		
    }
    return self;
}


//Setter for Room
- (void) setRoom:(Room *)newRoom {
    room = newRoom;
    
    // Move the meeting code into here, since it's all the same.
    
}


//Setter for Meeting
//- (void) setMeeting:(Meeting *)newMeeting {
//    meeting = newMeeting;
//	
//	NSDate *startingTime = [NSDate date];
//	NSLog(@"starting time in seconds: %f", [startingTime timeIntervalSince1970]);
//	NSTimeInterval startingTimeInSeconds = [startingTime timeIntervalSince1970] -1800;
//	
//	NSMutableArray *times=[[NSMutableArray alloc] initWithCapacity:6];
//	[times addObject:[NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]-1000]];
//	[times addObject:[NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]-600]];
//	[times addObject:[NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]-400]];
//	
//	TimerBar *timerBar=[[TimerBar alloc]initWithFrame: CGRectMake(0, 20, 300, 10) withStartTime:[NSDate dateWithTimeIntervalSince1970:startingTimeInSeconds] 
//							 withEventTimes:times];
//	
//	if(meeting!= nil){
//		[self addSubview:timerBar];
//	}   
//
//}
//Setter for Counted (Stores the number of members counted so far)
//- (void) setCounted:(int)newCounted {
//	
//    counted = newCounted;
//	NSLog(@"Counted in setCounted: %d", counted);
//}


//Fills Cell with Information on the room
- (void)drawRect:(CGRect)rect {
	NSLog(@"Drawing room cell");
    
    [room.name drawInRect:self.bounds withFont:[UIFont systemFontOfSize:24] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    
    
//	NSString *string = room ;
//	NSString *meetings;
//	if (meeting!= nil) {
//		if(![meeting.title isKindOfClass:[NSNull class]]){
//			meetings = [@"        \n\n  Meeting: " stringByAppendingString:meeting.title];
//		}
//		else{
//			meetings = [@"        \n\n  Meeting:" stringByAppendingString:@" No name"];
//		}
//	}
//	else{
//		meetings = [@"        \n\n  Meeting:" stringByAppendingString:@" No meeting"];
//	}
//		
//	[[UIColor blackColor] set];
//    [string drawInRect:self.bounds withFont:[UIFont systemFontOfSize:18] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
//	[meetings drawInRect:self.bounds withFont:[UIFont systemFontOfSize:12] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
//	
//	//NSLog(@"Counted: %@", [NSString stringWithFormat:@"%d",counted]);
//	NSString *countedPeople=[[NSString stringWithFormat:@"%d",counted] stringByAppendingString:@"    "];
//	NSString *numberPeople = [@"             \n\n# Attending:" stringByAppendingString: countedPeople];
//	[numberPeople drawInRect:self.bounds withFont:[UIFont systemFontOfSize:12] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentRight];
}

- (void)dealloc {
    [super dealloc];
}

@end
