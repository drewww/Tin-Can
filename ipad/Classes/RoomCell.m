//
//  RoomCell.m
//  Login
//
//  Created by Paula Jacobs on 6/30/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "RoomCell.h"
#import "TimerBar.h"
#import "Room.h"

@implementation RoomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
		CGRect tzvFrame = CGRectMake(0.0, 0.0, 320, self.contentView.bounds.size.height);
		
        roomCellView = [[RoomCellView alloc] initWithFrame:tzvFrame];
        roomCellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.contentView addSubview:roomCellView];
		
			

		
    }
    return self;
}

- (void)setRoom:(Room *)newRoom {
    
    [roomCellView setRoom:newRoom];
}

- (void)dealloc {
    [super dealloc];
}


@end
