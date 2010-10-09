//
//  LocationCellView.m
//  Login
//
//  Created by Drew Harry on 6/18/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "LocationCellView.h"
#import "Location.h"

@implementation LocationCellView

#define IN_THIS_MEETING 0
#define IN_OTHER_MEETING 1
#define UNUSED 3


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        self.opaque = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

//Setter for Location
- (void) setLoc:(Location *)newLoc {
    loc = newLoc;
}

- (void) setController:(LocationViewController *)theController {
    controller = theController;
}

// Fills the cell with information on Location
- (void)drawRect:(CGRect)rect {
	NSLog(@"drawing location cell");
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();


    // Check with the view controller to see if we have a room/meeting selected.
    // If we do, then change the display. We want to highlight locations that
    // are in that meeting, disable ones that are in other meetings. 
    int status;
    
    Room *selectedRoom = [controller getSelectedRoom];
    
    if(selectedRoom != nil && selectedRoom.currentMeeting==nil) {
        // Then it's a new meeting, which means we should be UNUSED
        // if we're not in a meeting and IN_OTHER_MEETING if we're
        // in any meeting at all.
        
        if(loc.meeting == nil) {
            status = UNUSED;
        } else {
            status = IN_OTHER_MEETING;
        }
    } else {
        // Otherwise, the room we're in HAS a meeting, so check to see if
        // that meeting matches or not.
        
        Meeting *selectedMeeting = [controller getSelectedRoom].currentMeeting;
        
        if(selectedMeeting==nil || loc.meeting.uuid == nil) {
            // If either the selected meeting is unset or the location this
            // cell represents is not in a meeting, then we stay in the unused
            // state.
            status = UNUSED;
        } else {
            
            if(selectedMeeting.uuid == loc.meeting.uuid) {
                status = IN_THIS_MEETING;
            } else {
                status = IN_OTHER_MEETING;
            }
        }
    }

    NSLog(@"STATUS: %d", status);
    
    if(status==IN_OTHER_MEETING) {
        self.alpha = 0.5;
        
        // Need some way to disable clicks.
        // This doesn't actually work.
        // TODO
        self.userInteractionEnabled = FALSE;
        
        
        self.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    } else if(status==UNUSED) {
        self.alpha = 1.0;
        self.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    } else if(status==IN_THIS_MEETING) {
        self.alpha = 1.0;
        self.backgroundColor = [UIColor whiteColor];
    }
    
    
    
    // what the hell? never seen this before. I guess it works(?)
    [[UIColor blackColor] set];
    [loc.name drawInRect:CGRectMake(5, 5, 285, 26) withFont:[UIFont systemFontOfSize:18] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    
    CGRect frameRect = CGRectMake(295, 5, 80, 50);
    CGRect labelRect = CGRectMake(295, 35, 80, 20);
    CGRect presentCountRect = CGRectMake(295, 5, 80, 30);
    
    CGRect meetingStatusRect = CGRectMake(5, 35, 200, 20);
    
    
    if(status==IN_OTHER_MEETING) {
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.4 alpha:1.0].CGColor);
        CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.4 alpha:1.0].CGColor);        
    } else {
        CGContextSetFillColorWithColor(ctx, loc.color.CGColor);
        CGContextSetStrokeColorWithColor(ctx, loc.color.CGColor);
    }
    
    CGContextFillRect(ctx, labelRect);
    CGContextStrokeRect(ctx, frameRect);
    
    // this'll do for now. Eventually we're going to want:
    // 1) list of users
    // 2) bolding on the title + room name, but not 'in'
    // 3) rounded corners on probably everything.
    
    if(loc.meeting == nil) {
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.4 alpha:1.0].CGColor);
        [@"Not in a meeting." drawInRect:meetingStatusRect withFont:[UIFont systemFontOfSize:12]];
    } else {
        
        CGContextFillRect(ctx, meetingStatusRect);
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
        
        NSString *fullMeetingString;
        if([loc.meeting.title length] > 20) {
            fullMeetingString = [NSString stringWithFormat:@"%@... in %@", [loc.meeting.title substringToIndex:20], loc.meeting.room.name];
        } else {
            fullMeetingString = [NSString stringWithFormat:@"%@ in %@", loc.meeting.title, loc.meeting.room.name];            
        }
            
        [fullMeetingString drawInRect:CGRectInset(meetingStatusRect, 2, 2) withFont:[UIFont boldSystemFontOfSize:12]];
    }
    
    
    NSString *numPeople = [NSString stringWithFormat:@"%d", [loc.users count]];
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    [numPeople drawInRect:presentCountRect withFont:[UIFont boldSystemFontOfSize:24] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
    
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);    
    [@"people" drawInRect:labelRect withFont:[UIFont boldSystemFontOfSize:14] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
    

}

- (void)dealloc {
    [super dealloc];
}


@end
