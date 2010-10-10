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

    // Set up the timer bar.
    if(room.currentMeeting != nil) {
        
        
        // For now, this is all bad data. We'll make it work off real data soon. 
    	TimerBar *timerBar=[[TimerBar alloc]initWithFrame: CGRectMake(10, 80, 270, 10) withMeeting:room.currentMeeting];
    	
   		[self addSubview:timerBar];
   	}       
}

//Fills Cell with Information on the room
- (void)drawRect:(CGRect)rect {
	NSLog(@"Drawing room cell");
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    // Think about doing something interesting if there's no non-default title - show the names of 
    // participants to help suggest to people what might be going on? 
    
    int numParticipants = 0;
    bool newMeeting = false;
    NSString *meetingTitle;
    if(room.currentMeeting != nil) {
        NSLog(@"This room has a meeting in it, do the meeting view version.");
        
        // Grab the meeting name.
        meetingTitle = room.currentMeeting.title;
        
        if([meetingTitle isKindOfClass:[NSNull class]]) {
                meetingTitle = @"Untitled Meeting";
        }
        
        numParticipants = [room.currentMeeting.currentParticipants count];
        
        newMeeting = false;
        
    } else {
        NSLog(@"No meeting in this room, just put up a 'start a meeting' notice.");
        
        meetingTitle = @"Start a new meeting here";
        numParticipants = 0;
        newMeeting = true;
    }
    
    // Draw things differently if it's a new meeting versus an existing meeting. Dim the text some,
    // and don't draw the people counter. Basically, try to make rooms with meetings stand out in
    // a bunch of different ways. 
    
    if(!newMeeting) {
        CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    } else {
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.4 alpha:1.0].CGColor);
    }

    [meetingTitle drawInRect:CGRectMake(10, 10, 270, 46) withFont:[UIFont systemFontOfSize:20]];
        
    // Now do the generic stuff, like drawing the room name and participant counter.
    
    CGRect roomNameRect = CGRectMake(290, 10, 80, 20);
    CGRect peopleCountRect = CGRectMake(290, 30, 80, 40);
    CGRect peopleLabelRect = CGRectMake(290, 70, 80, 20);
    CGRect totalRect = CGRectMake(290, 10, 80, 80);

    if(newMeeting) {
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.4 alpha:1.0].CGColor);
    } else {
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.37 green:.55 blue:.6 alpha:1].CGColor);
    }
    CGContextFillRect(ctx, roomNameRect);
    
    if(!newMeeting) {
        CGContextFillRect(ctx, peopleLabelRect);

        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextFillRect(ctx, peopleCountRect);
        
        CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:0.37 green:.55 blue:.6 alpha:1].CGColor);
        CGContextStrokeRect(ctx, totalRect);
    }

    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    [[room.name uppercaseString] drawInRect:roomNameRect withFont:[UIFont boldSystemFontOfSize:16] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
    
    if (!newMeeting) {
        [@"people" drawInRect:peopleLabelRect withFont:[UIFont boldSystemFontOfSize:16] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
        
        CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
        NSString *participantsCountString = [NSString stringWithFormat:@"%d", numParticipants];
        [participantsCountString drawInRect:peopleCountRect withFont:[UIFont boldSystemFontOfSize:30] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];       
    }
}

- (void)dealloc {
    [super dealloc];
}

@end
