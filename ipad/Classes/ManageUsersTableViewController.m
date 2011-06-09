//
//  ManageUsersTableViewController.m
//  TinCan
//
//  Created by Drew Harry on 6/8/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "ManageUsersTableViewController.h"
#import "StateManager.h"

@implementation ManageUsersTableViewController

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    
    return self;
}

- (void)extended {
    
    NSLog(@"in view will appear");
    
    // Set up the list, pulling users from the StateManager.
    // We want to do this each time the list is shown, so it's up to date.
    
    NSMutableSet *allUsersSet = [NSMutableSet setWithSet:[[StateManager sharedInstance] getUsers]];
    
    NSLog(@"got the set of all users: %@", allUsersSet);
    
//    [allUsersSet minusSet:[StateManager sharedInstance].meeting.currentParticipants];
    
//    NSLog(@"set minus current participants: %@", allUsersSet);
    
    if(allUsers != nil) {
        [allUsers release];
    }
    allUsers = [allUsersSet sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:NO]]];
    [allUsers retain];
    
    NSLog(@"final allUsers array: %@", allUsers);
    
    [self setTitle:@"Manage Location Members"];
    [self.view scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}


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
    NSLog(@"getting number of rows: %@", allUsers);
    return [allUsers count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@" IN CELL FOR ROW");
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    User *thisUser = (User *)[allUsers objectAtIndex:indexPath.row];
    
    cell.textLabel.text = thisUser.name;
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"didSelectRowAtIndexPath: %@", indexPath);
    
//    if(_delegate != nil) {
//        [self.delegate userSelected:[allUsers objectAtIndex:indexPath.row]];
//    }
}


@end
