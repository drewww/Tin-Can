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
	Meeting *meeting;
	int counted;
	
	TimerBar *timerBar;
	
}

- (void) setRoom:(NSString *)room;
- (void) setMeeting:(Meeting *)meeting;
- (void) setCounted:(int)counted;

@end
