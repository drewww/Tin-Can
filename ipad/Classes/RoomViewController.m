
//  RoomViewController2.m
//  Room
//
//  Created by Paula Jacobs on 6/29/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "RoomViewController.h"
#import "RoomCell.h"
#import "LoginMasterViewController.h"
#import "Room.h"
#import "StateManager.h"
#import "ConnectionManager.h"


@implementation RoomViewController

@synthesize roomList;
@synthesize meetingList;
@synthesize countedList;
#define ROW_HEIGHT 60

- (id)initWithFrame:(CGRect)frame withController:(LoginMasterViewController *)control{
	if (self = [super init]) {
		controller=control;
		self.view = [[[UITableView alloc] initWithFrame:CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), 400, 500) style:UITableViewStyleGrouped] autorelease];
		
		[(UITableView *)self.view setDelegate:self];
		[(UITableView *)self.view setDataSource:self];
		
		[self.view setBackgroundColor:[UIColor clearColor]];

		//self.countedList = [NSMutableArray array];
		
		ConnectionManager *conMan = [ConnectionManager sharedInstance];
		[conMan addListener:self];
		
		self.roomList = [[NSMutableArray alloc] initWithArray:[[[StateManager sharedInstance] getRooms] allObjects]];
		NSLog(@" Rooms list: %@", [[StateManager sharedInstance] getRooms]);
			
//		[countedList addObject:@"16"];
//		[countedList addObject:@"55"];
//		[countedList addObject:@"1"];
//		[countedList addObject:@"27"];
//		[countedList addObject:@"0"];
//		[countedList addObject:@"0"];
//		[countedList addObject:@"5"];
		
		[self.view setTransform:CGAffineTransformMakeRotation(M_PI/2)];
	}
	return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[controller chooseRoomWithRoom:[roomList objectAtIndex:indexPath.row] withMeeting:[meetingList objectAtIndex:indexPath.row] withCount:[countedList objectAtIndex:indexPath.row]];	
} 


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


// There is only one section.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.roomList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    static NSString *CellIdentifier = @"RoomCell";
    
	RoomCell *testCell = (RoomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(testCell==nil) {
        testCell = [[[RoomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        testCell.frame = CGRectMake(0.0, 0.0, 320.0, ROW_HEIGHT);
    }
    
    Room *room = [roomList objectAtIndex:indexPath.row];
	testCell.room = room.name;	
	NSLog(@" Room names: %@", room.name);
	testCell.meeting=room.currentMeeting;
	NSLog(@" meeting: %@", room.currentMeeting);	
	testCell.counted = [[room.currentMeeting getCurrentParticipants] count];
	NSLog(@" Room number of People: %d", [[room.currentMeeting getCurrentParticipants] count]);
 	
    return testCell;
}



- (void)dealloc {
    [super dealloc];
}

@end
