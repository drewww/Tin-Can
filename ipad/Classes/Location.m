//
//  Location.m
//  TinCan
//
//  Created by Drew Harry on 7/15/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "Location.h"
#import "StateManager.h"
#import "Meeting.h"


@implementation Location

@synthesize meeting;
@synthesize users;

- (id) initWithUUID:(NSString *)myUuid withName:(NSString *)myName withMeeting:(Meeting *)myMeeting withUsers:(NSSet *)myUsers {
    self = [super initWithUUID:myUuid withName:myName];
    
    self.meeting = myMeeting;
    
    // Make the mutable version of the set, then populate it
    // by unioning in the initialization set. self allows people
    // calling self constructor to use NSMutableSet or NSSet
    // and we don't care because we'll construct a fresh one for
    // our use.
    self.users = [NSMutableSet set];
    self.users = [self.users setByAddingObjectsFromSet:myUsers];
    
    return self;
}

- (void) userJoined:(User *)theUser {
    [self.users addObject:theUser];
    theUser.location = self;
}

- (void) userLeft:(User *)theUser {
    [self.users removeObject:theUser];
    theUser.location = nil;
}

- (void) joinedMeeting:(Meeting *)theMeeting {
    self.meeting = theMeeting;
}

- (void) leftMeeting:(Meeting *)theMeeting {
    self.meeting = nil;
}

- (BOOL) isInMeeting {
    return self.meeting != nil;
}

- (void) unswizzle {
       
    NSMutableSet *newUsersList = [[NSMutableSet set] autorelease];
    for(NSString *userUUID in self.users) {
        User *user = [[StateManager sharedInstance] getObjWithUUID:userUUID withType:User.class];
        [newUsersList addObject:user];
        user.location = self;
    }
    [self.users release];
    self.users = newUsersList;
    
    if(self.meeting != nil) {
        self.meeting = [[StateManager sharedInstance] getObjWithUUID:self.meeting withType:Meeting.class];
        [self.meeting locationJoined:self];
    }
}


@end
