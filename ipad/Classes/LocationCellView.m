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

// Fills the cell with information on Location
- (void)drawRect:(CGRect)rect {
	NSLog(@"drawing location cell");

    CGContextRef ctx = UIGraphicsGetCurrentContext();


    // what the hell? never seen this before. I guess it works(?)
    [[UIColor blackColor] set];
    [loc.name drawInRect:CGRectMake(5, 5, 285, 26) withFont:[UIFont systemFontOfSize:18] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    
    CGRect frameRect = CGRectMake(295, 5, 80, 50);
    CGRect labelRect = CGRectMake(295, 35, 80, 20);
    CGRect presentCountRect = CGRectMake(295, 5, 80, 30);
    
    CGRect meetingStatusRect = CGRectMake(5, 35, 200, 20);
    
    CGContextSetFillColorWithColor(ctx, loc.color.CGColor);
    CGContextSetStrokeColorWithColor(ctx, loc.color.CGColor);
    
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
        
        NSString *fullMeetingString = [NSString stringWithFormat:@"%@ in %@", loc.meeting.title, loc.meeting.room.name];
        [fullMeetingString drawInRect:meetingStatusRect withFont:[UIFont boldSystemFontOfSize:12]];
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
