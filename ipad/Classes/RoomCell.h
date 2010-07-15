//
//  RoomCell.h
//  Login
//
//  Created by Paula Jacobs on 6/30/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomCellView.h"

@interface RoomCell : UITableViewCell {
	RoomCellView *roomCellView;
    NSString *room;
	NSString *meeting;
	NSString *counted;
}

- (void) setRoom:(NSString *)room;
- (void) setMeeting:(NSString *)meeting;
- (void) setCounted:(NSString *)counted;

@property (nonatomic, retain) NSString *room;
@property (nonatomic, retain) NSString *meeting;
@property (nonatomic, retain) NSString *counted;
@end
