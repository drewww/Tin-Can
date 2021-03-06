//
//  LocationViewController.m
//  Login
//
//  Created by Drew Harry on 6/18/10.
//  Copyright MIT Media Lab 2010. All rights reserved.
//

#import "LocationViewController.h"
#import "LocationCell.h"
#import "LoginMasterViewController.h"
#import "StateManager.h"
#import "ConnectionManager.h"
#import "Location.h"
@implementation LocationViewController

@class LoginMasterViewController;
@synthesize locList;


#define ROW_HEIGHT 60

- (id)initWithFrame:(CGRect)frame withController:(LoginMasterViewController *)control{
	if (self = [super init]) {
		
		self.view = [[[UITableView alloc] 
					  initWithFrame:CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), 400, 500) style:UITableViewStyleGrouped] autorelease];
		[self.view setBackgroundColor:[UIColor clearColor]];
		
		[(UITableView *)self.view setDelegate:self];
		[(UITableView *)self.view setDataSource:self];
		
		
		controller=control;
		
		self.locList = [[NSMutableArray alloc] initWithArray:[[[StateManager sharedInstance] getLocations] allObjects]];
		//NSLog(@" Locations list: %@", [[StateManager sharedInstance] getLocations]);
        
		[self.view setTransform:CGAffineTransformMakeRotation(M_PI/2)];
        
        
        self.tableView.rowHeight = ROW_HEIGHT;
	}
	return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}



//Sends information to MasterViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    [controller chooseLocation:[locList objectAtIndex:indexPath.row]];	
}

- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)didReceiveMemoryWarning {	
    [super didReceiveMemoryWarning];
}


// There is only one section.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.locList count];
}


- (void) update {
	for (LocationCell *cell in [(UITableView *)self.view visibleCells]) {
		[cell setNeedsDisplay];
	}
}


// I really should be using the fancy synthesize stuff, but I don't feel
// like learning how right now. 

- (void) setSelectedRoom:(Room *)theSelectedRoom {
    selectedRoom = theSelectedRoom;
    
    // We need to push this into the view somehow, or have the view
    // call back home when it draws. Not sure which.
    [self update];
}

- (Room *) getSelectedRoom {
    return selectedRoom;
}

- (void) setSelectedLocation:(Location *)theSelectedLocation {
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[locList indexOfObject:theSelectedLocation] inSection:0] animated:true scrollPosition:UITableViewScrollPositionMiddle];
    
    [self update];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    static NSString *CellIdentifier = @"LoginCell";
    
	LocationCell *testCell = (LocationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(testCell==nil) {
        testCell = [[[LocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        testCell.frame = CGRectMake(0.0, 0.0, 320.0, ROW_HEIGHT);
    }
    //
    Location *loc = [locList objectAtIndex:indexPath.row];
	testCell.loc = loc;
    [testCell setController:self];
 	//NSLog(@" Location names: %@", loc.name);
	
    return testCell;
}


- (void)dealloc {
    [super dealloc];
}

@end