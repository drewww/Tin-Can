//
//  Meeting.m
//  TinCan
//
//  Created by Drew Harry on 7/15/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "Meeting.h"
#import "Location.h"
#import "StateManager.h"
#import "Room.h"
#import "Task.h"
#import "Topic.h"

@implementation Meeting

@synthesize room;
@synthesize title;
@synthesize locations;
@synthesize allParticipants;
@synthesize currentParticipants;
@synthesize startedAt;

@synthesize tasks;
@synthesize topics;

- (id) initWithUUID:(NSString *)myUuid withTitle:(NSString *)myTitle withRoomUUID:(NSString *)myRoomUUID startedAt:(NSDate *)myStartedAt {
    self = [super initWithUUID:myUuid];
 
    self.locations = [NSMutableSet set];
    
    allParticipants = [[NSMutableSet set] retain];  
    currentParticipants = [[NSMutableSet set] retain];
    
    self.title = myTitle;
    self.room = nil;
    roomUUID = myRoomUUID;
    
    self.startedAt = myStartedAt;
    
    topics = [[NSMutableSet set] retain];
    tasks = [[NSMutableSet set] retain];
        
    return self;
}

- (void) userJoined:(User *)theUser theLocation:(Location *)theLocation {
    [allParticipants addObject:theUser];
    [currentParticipants addObject:theUser];
}

- (void) userLeft:(User *)theUser theLocation:(Location *)theLocation {
    [currentParticipants removeObject:theUser];
}

- (void) locationJoined:(Location *)theLocation {
    [self.locations addObject:theLocation];
    [theLocation joinedMeeting:self];
    
    for(User *user in [[theLocation.users copy] autorelease]) {
        [self userJoined:user theLocation:theLocation];
    }
}

- (void) locationLeft:(Location *)theLocation {
    // Remove that location's associated users.
    for (User *user in theLocation.users) {
        [self userLeft:user theLocation:theLocation];
    }
    
    [theLocation leftMeeting:self];
    [self.locations removeObject:theLocation];
}

- (void) addTask:(id)newTask {
    [self.tasks addObject:newTask];
}

- (void) removeTask:(id)removeTask {
    [self.tasks removeObject:removeTask];
}

- (void) addTopic:(id)newTopic {
    [self.topics addObject:newTopic];
}

- (void) removeTopic:(id)removeTopic {
    [self.topics removeObject:removeTopic];   
}

- (NSSet *) getUnassignedTasks {
    NSMutableSet *unassignedTasks = [NSMutableSet set];
    
    for (Task *task in [[self.tasks copy] autorelease]) {
        if(![task isAssigned]) {
            [unassignedTasks addObject:task];
        }
    }
    return unassignedTasks;
}

- (Topic *) getCurrentTopic {
    // Just gonna iterate through all the topics and look for one with "CURRENT" as its status.
    for (Topic *t in self.topics) {
        if(t.status == kCURRENT) {
            return t;
        }
    }
    
    return nil;
}

// Returns just topics that have not been started yet.
- (NSSet *) getUpcomingTopics {
    NSMutableSet *upcomingTopics = [NSMutableSet set];
    
    for (Topic *t in self.topics) {
        if(t.status==kFUTURE) {
            [upcomingTopics addObject:t];
        }
    }
    
    return [NSSet setWithSet:upcomingTopics];
}

- (void) unswizzle {

    self.room = (Room *)[[StateManager sharedInstance] getObjWithUUID:roomUUID withType:Room.class];
    
    // Turn this on when the room class is written.
	NSLog(@"about to unswizzle, meeting uuid: %@", roomUUID);
    self.room.currentMeeting = self;
	NSLog(@"room: %@", self.room);
}

- (NSString *) description {
    return [NSString stringWithFormat:@"[meeting.%@ %@ locs:%d users:%d started:%@ topics:%d tasks:%d]", [self.uuid substringToIndex:6],
            self.title, [self.locations count], [self.currentParticipants count], self.startedAt, [topics count], [tasks count]];
}

@end
