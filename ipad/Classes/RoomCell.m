//
//  RoomCell.m
//  Login
//
//  Created by Paula Jacobs on 6/30/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "RoomCell.h"
#import "TimerBar.h"

@implementation RoomCell


//@synthesize room;
//@synthesize meeting;
//@synthesize counted;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
		CGRect tzvFrame = CGRectMake(0.0, 0.0, 320, self.contentView.bounds.size.height);
		
        roomCellView = [[RoomCellView alloc] initWithFrame:tzvFrame];
        roomCellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.contentView addSubview:roomCellView];
		
		
		NSDate *startingTime = [NSDate date];
		NSLog(@"starting time in seconds: %f", [startingTime timeIntervalSince1970]);
		NSTimeInterval startingTimeInSeconds = [startingTime timeIntervalSince1970] -1800;
		
		NSMutableArray *times=[[NSMutableArray alloc] initWithCapacity:6];
		[times addObject:[NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]-1000]];
		[times addObject:[NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]-600]];
		[times addObject:[NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]-400]];
		timerBar=[[TimerBar alloc]initWithFrame: CGRectMake(0, 20, 300, 10) withStartTime:[NSDate dateWithTimeIntervalSince1970:startingTimeInSeconds] 
					 withEventTimes:times];
		[self.contentView addSubview:timerBar];
		

		
    }
    return self;
}

- (void)setRoom:(NSString *)newRoom {
    
    [roomCellView setRoom:newRoom];
}
- (void)setMeeting:(NSString *)newMeeting {
    
    [roomCellView setMeeting:newMeeting];
}
- (void) setCounted:(int)newCounted {
    [roomCellView setCounted:newCounted];
}

- (void)dealloc {
    [super dealloc];
}


@end
