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

- (id) initWithUUID:(NSString *)myUuid withTitle:(NSString *)myTitle withRoomUUID:(NSString *)myRoomUUID {
    self = [super initWithUUID:myUuid];
 
    self.title = myTitle;
    self.room = nil;
    roomUUID = myRoomUUID;
    
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
    
    for(User *user in theLocation.users) {
        [self userJoined:user theLocation:theLocation];
    }
}

- (void) locationLeft:(Location *)theLocation {
    [theLocation leftMeeting:self];
    [self.locations removeObject:theLocation];
}

- (NSSet *)getCurrentParticipants {
    
    // I'm pretty sure I should autorelease this - I'm not retaining it, and it's
    // the job of the code calling this method to retain it if they want it. But
    // will it get garbage collected before it returns if I autorelease it? I think
    // not, but I'm not 100% sure.
    NSMutableSet *currentParticipants = [[NSMutableSet set] autorelease];
    
    for (Location *location in self.locations) {
        [currentParticipants addObjectsFromArray:[location.users allObjects]];
    }
    
    return currentParticipants;
}

- (void) unswizzle {

    self.room = (Room *)[[StateManager sharedInstance] getObjWithUUID:roomUUID withType:Room.class];
    
    // Turn this on when the room class is written.
    self.room.currentMeeting = self;
}


@end
