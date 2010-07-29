//
//  RoomCellView.m
//  Login
//
//  Created by Paula Jacobs on 6/30/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "RoomCellView.h"
#import "TimerBar.h"


@implementation RoomCellView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        self.opaque = YES;
        self.backgroundColor = [UIColor clearColor];

    }
    return self;
}


//Setter for Room
- (void) setRoom:(NSString *)newRoom {
    room = newRoom;
}


//Setter for Meeting
- (void) setMeeting:(NSString *)newMeeting {
    meeting = newMeeting;
}
//Setter for Counted (Stores the number of members counted so far)
- (void) setCounted:(int)newCounted {
	
    counted = newCounted;
	NSLog(@"Counted in setCounted: %d", counted);
}


//Fills Cell with Information on the room
- (void)drawRect:(CGRect)rect {
	NSLog(@"I'm Drawing!");
	NSString *string = room ;
	NSString *meetings;
	if (meeting!= nil) {
	
		meetings = [@"        \n\n  Meeting: " stringByAppendingString:meeting];
	}
	else{
		meetings = [@"        \n\n  Meeting:" stringByAppendingString:@" No meeting"];
	}
		
	[[UIColor blackColor] set];
    [string drawInRect:self.bounds withFont:[UIFont systemFontOfSize:18] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
	[meetings drawInRect:self.bounds withFont:[UIFont systemFontOfSize:12] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
	
	//NSLog(@"Counted: %@", [NSString stringWithFormat:@"%d",counted]);
	NSString *countedPeople=[[NSString stringWithFormat:@"%d",counted] stringByAppendingString:@"    "];
	NSString *numberPeople = [@"             \n\n# Attending:" stringByAppendingString: countedPeople];
	[numberPeople drawInRect:self.bounds withFont:[UIFont systemFontOfSize:12] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentRight];
}

- (void)dealloc {
    [super dealloc];
}

@end
