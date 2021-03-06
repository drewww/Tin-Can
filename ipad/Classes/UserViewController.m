//
//  LocationViewController.m
//  Login
//
//  Created by Drew Harry on 6/18/10.
//  Copyright MIT Media Lab 2010. All rights reserved.
//

#import "UserViewController.h"
#import "UserCell.h"
#import "LoginMasterViewController.h"
#import "StateManager.h"
#import "ConnectionManager.h"
#import "User.h"

@implementation UserViewController

@class LoginMasterViewController;
@synthesize userList;


#define ROW_HEIGHT 60

- (id)initWithFrame:(CGRect)frame withController:(LoginMasterViewController *)control{
	if (self = [super init]) {
		
		self.view = [[[UITableView alloc] 
					  initWithFrame:CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), 400, 500) style:UITableViewStyleGrouped] autorelease];
		[self.view setBackgroundColor:[UIColor clearColor]];
		
		[(UITableView *)self.view setDelegate:self];
		[(UITableView *)self.view setDataSource:self];
		
		
		controller=control;
		
		self.userList = [[NSMutableArray alloc] initWithArray:[[[StateManager sharedInstance] getUsers] allObjects]];
        
        NSSortDescriptor *descriptor =
        [[[NSSortDescriptor alloc]
          initWithKey:@"name"
          ascending:YES
          selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
        
        NSArray * descriptors = [NSArray arrayWithObjects:descriptor, nil];

        [self.userList sortUsingDescriptors:descriptors];

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
	
    [controller chooseUser:[userList objectAtIndex:indexPath.row]];	
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
	return [self.userList count];
}


- (void) update {
	for (UserCell *cell in [(UITableView *)self.view visibleCells]) {
		[cell setNeedsDisplay];
	}
}


// I really should be using the fancy synthesize stuff, but I don't feel
// like learning how right now. 

- (void) setSelectedUser:(User *)theSelectedUser {
    selectedUser = theSelectedUser;
    
    // We need to push this into the view somehow, or have the view
    // call back home when it draws. Not sure which.
    [self update];
}

- (User *) getSelectedUser {
    return selectedUser;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    static NSString *CellIdentifier = @"LoginCell";
    
	UserCell *testCell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(testCell==nil) {
        testCell = [[[UserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        testCell.frame = CGRectMake(0.0, 0.0, 320.0, ROW_HEIGHT);
    }
    //
    User *user = [userList objectAtIndex:indexPath.row];
	testCell.user = user;
    [testCell setController:self];
    [testCell setNeedsDisplay];

    return testCell;
}


- (void)dealloc {
    [super dealloc];
}

@end
