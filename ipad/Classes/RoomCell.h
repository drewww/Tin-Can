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
#import "Room.h"

@interface RoomCell : UITableViewCell {
	RoomCellView *roomCellView;
}

- (void) setRoom:(Room *)room;

@end
