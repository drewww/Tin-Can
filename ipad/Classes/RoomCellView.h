//
//  RoomCellView.h
//  Login
//
//  Created by Paula Jacobs on 6/30/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimerBar.h"
#import "Meeting.h"

@interface RoomCellView : UIView {
	NSString *room;
	Meeting *meeting;
	int counted;

}


- (void) setRoom:(NSString *)newRoom;
- (void) setMeeting:(Meeting *)newMeeting;
- (void) setCounted:(int)newCounted;

@end
