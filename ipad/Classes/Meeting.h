//
//  Meeting.h
//  TinCan
//
//  Created by Drew Harry on 7/15/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynchronizedObject.h"
#import "Room.h"
#import "User.h"
#import "Location.h"
#import "tincan.h"

@class Room;
@class User;
@class Location;

@interface Meeting : SynchronizedObject {
    Room *room;
    UUID *roomUUID;
    
    NSString *title;
    
    NSMutableSet *allParticipants;
    NSMutableSet *locations;
}

- (id) initWithUUID:(UUID *)myUuid withTitle:(NSString *)myTitle withRoomUUID:(UUID *)myRoomUUID;

- (void) userJoined:(User *)theUser theLocation:(Location *)theLocation;
- (void) userLeft:(User *)theUser theLocation:(Location *)theLocation;

- (void) locationJoined:(Location *)theLocation;
- (void) locationLeft:(Location *)theLocation;

- (NSSet *)getCurrentParticipants;

- (void) unswizzle;


@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSMutableSet *allParticipants;
@property(nonatomic, retain) Room *room;
@property(nonatomic, retain) NSMutableSet *locations;

@end
