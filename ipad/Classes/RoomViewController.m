
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
		
		
		self.roomList = [NSMutableArray array];
		//self.meetingList = [NSMutableArray array];
		//self.countedList = [NSMutableArray array];
		
		ConnectionManager *conMan = [ConnectionManager sharedInstance];
		[conMan addListener:self];
		
		self.roomList = [[NSMutableArray alloc] initWithArray:[[[StateManager sharedInstance] getRooms] allObjects]];
		NSLog(@" Rooms list: %@", [[StateManager sharedInstance] getRooms]);
		
		//[roomList addObject:@"Queen's Garden"];
//		[roomList addObject:@"Chessboard Forest"];
//		[roomList addObject:@"Bizzare Room"];
//		[roomList addObject:@"Rabbit Hole"];
//		[roomList addObject:@"Mad Hatter's House"];
//		[roomList addObject:@"March Hare's House"];
//		[roomList addObject:@"CourtRoom"];
		
		//[meetingList addObject:@"Very Important"];
//		[meetingList addObject:@"#120391"];
//		[meetingList addObject:@"#3.14159"];
//		[meetingList addObject:@"Dinner"];
//		[meetingList addObject:@"Empty"];
//		[meetingList addObject:@"Empty"];
//		[meetingList addObject:@"Trial"];
//		
//		[countedList addObject:@"16"];
//		[countedList addObject:@"55"];
//		[countedList addObject:@"1"];
//		[countedList addObject:@"27"];
//		[countedList addObject:@"0"];
//		[countedList addObject:@"0"];
//		[countedList addObject:@"5"];
		
	//	[roomList addObject:@"Queen's Garden"];
//		[roomList addObject:@"Chessboard Forest"];
//		[roomList addObject:@"Bizzare Room"];
//		[roomList addObject:@"Rabbit Hole"];
//		[roomList addObject:@"Mad Hatter's House"];
//		[roomList addObject:@"March Hare's House"];
//		[roomList addObject:@"CourtRoom"];
	//	
//		[meetingList addObject:@"Very Important"];
//		[meetingList addObject:@"#120391"];
//		[meetingList addObject:@"#3.14159"];
//		[meetingList addObject:@"Dinner"];
//		[meetingList addObject:@"Empty"];
//		[meetingList addObject:@"Empty"];
//		[meetingList addObject:@"Trial"];
		//
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
	//NSString *meeting = [meetingList objectAtIndex:indexPath.row];
	testCell.meeting = room.currentMeeting.title;
	NSString *counted = [[NSNumber numberWithInteger: [[room.currentMeeting getCurrentParticipants] count]] stringValue];
	testCell.counted = counted;
 	
    return testCell;
}



- (void)dealloc {
    [super dealloc];
}

@end
