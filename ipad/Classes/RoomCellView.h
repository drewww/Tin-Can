//
//  RoomCellView.h
//  Login
//
//  Created by Paula Jacobs on 6/30/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimerBar.h"
#import "Room.h"

@interface RoomCellView : UIView {

	Room *room;
}


- (void) setRoom:(Room *)newRoom;

@end
