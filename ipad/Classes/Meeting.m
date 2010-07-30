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


@implementation Meeting

@synthesize room;
@synthesize title;
@synthesize locations;
@synthesize allParticipants;
@synthesize startedAt;

@synthesize tasks;
@synthesize topics;

- (id) initWithUUID:(NSString *)myUuid withTitle:(NSString *)myTitle withRoomUUID:(NSString *)myRoomUUID startedAt:(NSDate *)myStartedAt {
    self = [super initWithUUID:myUuid];
 
    self.title = myTitle;
    self.room = nil;
    roomUUID = myRoomUUID;
    
    self.startedAt = myStartedAt;
    
    topics = [NSMutableSet set];
    tasks = [NSMutableSet set];
        
    return self;
}

- (void) userJoined:(User *)theUser theLocation:(Location *)theLocation {
    [self.allParticipants addObject:theUser];
}

- (void) userLeft:(User *)theUser theLocation:(Location *)theLocation {
    // nothing to do here, really. Maybe something someday.
}

- (void) locationJoined:(Location *)theLocation {
    [self.locations addObject:theLocation];
    [theLocation joinedMeeting:self];
    
    for(User *user in [[theLocation.users copy] autorelease]) {
        [self userJoined:user theLocation:theLocation];
    }
}

- (void) locationLeft:(Location *)theLocation {
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


- (NSSet *)getCurrentParticipants {
    
    // I'm pretty sure I should autorelease this - I'm not retaining it, and it's
    // the job of the code calling this method to retain it if they want it. But
    // will it get garbage collected before it returns if I autorelease it? I think
    // not, but I'm not 100% sure.
    NSMutableSet *currentParticipants = [NSMutableSet set];
    
    for (Location *location in self.locations) {
        [currentParticipants addObjectsFromArray:[location.users allObjects]];
    }
    
    return currentParticipants;
}

- (void) unswizzle {

    self.room = (Room *)[[StateManager sharedInstance] getObjWithUUID:roomUUID withType:Room.class];
    
    // Turn this on when the room class is written.
	NSLog(@"about to unswizzle, meeting uuid: %@", roomUUID);
    self.room.currentMeeting = self;
	NSLog(@"room: %@", self.room);
}

- (NSString *) description {
    return [NSString stringWithFormat:@"[meeting.%@ %@ locs:%d users:%d started:%@]", [self.uuid substringToIndex:6],
            self.title, [self.locations count], [[self getCurrentParticipants] count], self.startedAt];
}

@end
