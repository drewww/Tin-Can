//
//  ManageUsersTableViewController.m
//  TinCan
//
//  Created by Drew Harry on 6/8/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "ManageUsersTableViewController.h"
#import "StateManager.h"
#import "ConnectionManager.h"

@implementation ManageUsersTableViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    
//    self.view = [[[UITableView alloc] 
//                  initWithFrame:CGRectMake(0, 0, 300, 650) style:UITableViewStylePlain] autorelease];
////    [self.view setBackgroundColor:[UIColor clearColor]];
//    
//    [(UITableView *)self.view setDelegate:self];
//    [(UITableView *)self.view setDataSource:self];
//    
//    [self.view setTransform:CGAffineTransformMakeRotation(M_PI/2)];
    
//    self.tableView.rowHeight = ROW_HEIGHT;
    
    
//    [self addSubview:tableController.view];

    self.view.bounds = CGRectMake(0, 0, 300, 555);
    
    [self updateUsers];
    
    return self;
}


- (void)updateUsers {
    
    userList = [[NSMutableArray alloc] initWithArray:[[[StateManager sharedInstance] getUsers] allObjects]];
    
    NSSortDescriptor *descriptor =
    [[[NSSortDescriptor alloc]
      initWithKey:@"name"
      ascending:YES
      selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
    
    NSArray * descriptors = [NSArray arrayWithObjects:descriptor, nil];
    
    [userList sortUsingDescriptors:descriptors];
    
    // now loop through them and see if they're in our location. If they are, then mark them as such.
    NSLog(@"IN UPDATE USERS");
    Location *ourLocation = [StateManager sharedInstance].location;
    NSLog(@"Location users: %@", ourLocation.users);
    for (User *user in ourLocation.users) {
        // Check them off.
        [self setUser:user toSelectedState:true];
    }
    
    
}

//- (void)extended {
//    
//    NSLog(@"in view will appear");
//    
//    // Set up the list, pulling users from the StateManager.
//    // We want to do this each time the list is shown, so it's up to date.
//    
//    NSMutableSet *allUsersSet = [NSMutableSet setWithSet:[[StateManager sharedInstance] getUsers]];
//    
//    NSLog(@"got the set of all users: %@", allUsersSet);
//    
////    [allUsersSet minusSet:[StateManager sharedInstance].meeting.currentParticipants];
//    
////    NSLog(@"set minus current participants: %@", allUsersSet);
//    
//    if(userList != nil) {
//        [userList release];
//    }
//    userList = [allUsersSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]];
//    [userList retain];
//    
//    NSLog(@"final allUsers array: %@", userList);
//    
//    [self setTitle:@"Manage Location Members"];
//    [self.view scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
//}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return NO;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSLog(@"getting number of rows: %@", userList);
    return [userList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@" IN CELL FOR ROW");
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    User *thisUser = (User *)[userList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = thisUser.name;
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *thisCell = [tableView cellForRowAtIndexPath:indexPath];
    
    
    if (thisCell.accessoryType == UITableViewCellAccessoryNone) {
        [self setRow:indexPath toSelectedState:true];
    }else{
        [self setRow:indexPath toSelectedState:false];        
    }
    
//    if(_delegate != nil) {
//        [self.delegate userSelected:[allUsers objectAtIndex:indexPath.row]];
//    }
}

- (void)setUser:(User *)user toSelectedState:(bool) selected {
    [self setRow:[NSIndexPath indexPathForRow:[userList indexOfObject:user] inSection:0] toSelectedState:selected];
}

- (void)setRow:(NSIndexPath *)indexPath toSelectedState:(bool) selected{
    
    UITableViewCell *thisCell = [self.view cellForRowAtIndexPath:indexPath];
    
    
    bool currentState = false;
    if(thisCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        // It's already selected. We want to detect transitions.
        currentState = true;
    }
    
    if (selected) {
        thisCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    }else{
        thisCell.accessoryType = UITableViewCellAccessoryNone;
        
    }
    
    if(selected==true && currentState == false) {
        // Then we need to have them join.
        [[ConnectionManager sharedInstance] joinLocation:[StateManager sharedInstance].location withUser:[userList objectAtIndex:indexPath.row]];
    } else if(selected==false && currentState == true) {
        // have them leave!
        [[ConnectionManager sharedInstance] leaveLocation:[StateManager sharedInstance].location withUser:[userList objectAtIndex:indexPath.row]];
    }
    
}


@end
