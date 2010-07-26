//
//  RoomCell.h
//  Login
//
//  Created by Paula Jacobs on 6/30/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomCellView.h"
#import "TimerBar.h"

@interface RoomCell : UITableViewCell {
	RoomCellView *roomCellView;
    NSString *room;
	NSString *meeting;
	NSString *counted;
	
	TimerBar *timerBar;
	NSTimer *clock;
}

- (void) setRoom:(NSString *)room;
- (void) setMeeting:(NSString *)meeting;
- (void) setCounted:(NSString *)counted;
- (void)clk;
@property (nonatomic, retain) NSString *room;
@property (nonatomic, retain) NSString *meeting;
@property (nonatomic, retain) NSString *counted;
@end
