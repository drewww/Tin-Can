//
//  RoomCellView.m
//  Login
//
//  Created by Paula Jacobs on 6/30/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "RoomCellView.h"


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
- (void) setCounted:(NSString *)newCounted {
    counted = newCounted;
}


//Fills Cell with Information on the room
- (void)drawRect:(CGRect)rect {
	NSString *string = room ;
	
	NSString *meetings = [@"        \n\n  Meeting:" stringByAppendingString:meeting];
	NSString *countedPeople=[counted stringByAppendingString:@"    "];
	NSString *numberPeople = [@"             \n\n# Attending:" stringByAppendingString: countedPeople];
	
	[[UIColor blackColor] set];
    [string drawInRect:self.bounds withFont:[UIFont systemFontOfSize:18] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
	[numberPeople drawInRect:self.bounds withFont:[UIFont systemFontOfSize:12] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentRight];
	[meetings drawInRect:self.bounds withFont:[UIFont systemFontOfSize:12] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
}

- (void)dealloc {
    [super dealloc];
}

@end
