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

@implementation LocationViewController

@class LoginMasterViewController;
@synthesize locList;


#define ROW_HEIGHT 60

- (id)initWithFrame:(CGRect)frame withController:(LoginMasterViewController *)control{
	if (self = [super init]) {
		
		self.view = [[[UITableView alloc] initWithFrame:CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), 400, 500) style:UITableViewStyleGrouped] autorelease];
		[self.view setBackgroundColor:[UIColor clearColor]];
		
		[(UITableView *)self.view setDelegate:self];
		[(UITableView *)self.view setDataSource:self];
		
		
		controller=control;
		
		
		//fills our List of Possible Locations
		self.locList = [NSMutableArray array];
		[locList addObject:@"Here"];
		[locList addObject:@"There"];
		[locList addObject:@"Everywhere"];
		[locList addObject:@"Underwear"];
		[locList addObject:@"In Your Hair"];
		[locList addObject:@"Fight a Bear"];
		[locList addObject:@"With Your Chair"];
		[locList addObject:@"Here"];
		[locList addObject:@"There"];
		[locList addObject:@"Everywhere"];
		[locList addObject:@"Underwear"];
		[locList addObject:@"In Your Hair"];
		[locList addObject:@"Fight a Bear"];
		[locList addObject:@"With Your Chair"];
		
		
	}
	return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}



//Sends information to MasterViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    [controller chooseLocationWithLocation:[locList objectAtIndex:indexPath.row]];
  
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



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    
    static NSString *CellIdentifier = @"LoginCell";
    
	LocationCell *testCell = (LocationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(testCell==nil) {
        testCell = [[[LocationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        testCell.frame = CGRectMake(0.0, 0.0, 320.0, ROW_HEIGHT);
    }
    
    NSString *loc = [locList objectAtIndex:indexPath.row];
	testCell.loc = loc;
 	
    return testCell;
}


- (void)dealloc {
    [super dealloc];
}

@end
