
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
#define ROW_HEIGHT 100

- (id)initWithFrame:(CGRect)frame withController:(LoginMasterViewController *)control{
	if (self = [super init]) {
		controller=control;
		self.view = [[[UITableView alloc] initWithFrame:CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), 400, 500) style:UITableViewStyleGrouped] autorelease];
		
		[(UITableView *)self.view setDelegate:self];
		[(UITableView *)self.view setDataSource:self];
		
		[self.view setBackgroundColor:[UIColor clearColor]];

		
		//ConnectionManager *conMan = [ConnectionManager sharedInstance];
		//[conMan addListener:self];
		
		self.roomList = [[NSMutableArray alloc] initWithArray:[[[StateManager sharedInstance] getRooms] allObjects]];
		NSLog(@" Rooms list: %@", [[StateManager sharedInstance] getRooms]);
        
		[self.view setTransform:CGAffineTransformMakeRotation(M_PI/2)];
        
        self.tableView.rowHeight = ROW_HEIGHT;
	}
	return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[controller chooseRoom:[roomList objectAtIndex:indexPath.row]];
} 


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void) update {
	NSLog(@"updating room cells.");
	for (RoomCell *cell in [(UITableView *)self.view visibleCells]) {
		NSLog(@"updating room cell: %@", cell);
		[cell setNeedsDisplay];
	}
    
    [self.view setNeedsDisplay];
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
        
        // This actually more like 400. The container tableview is 400 wide, so the resulting cells
        // are probably more like 380-390 wide. Not 100% sure. 
        testCell.frame = CGRectMake(0.0, 0.0, 320.0, ROW_HEIGHT);
    }
    
    Room *room = [roomList objectAtIndex:indexPath.row];
	[testCell setRoom:room];
  	
    return testCell;
}



- (void)dealloc {
    [super dealloc];
}

@end
