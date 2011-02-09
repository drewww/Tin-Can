//
//  StateManager.h
//  TinCan
//
//  Created by Drew Harry on 7/14/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tincan.h"
#import "Actor.h"
#import "Meeting.h"
#import "Location.h"

@interface StateManager : NSObject {
    NSMutableDictionary *db;
    
    Meeting *meeting;
    Location *location;
    User *user;
    
    NSMutableSet *actors;
    NSMutableSet *rooms;
    NSMutableSet *meetings;
}

- (void) putObj:(NSObject *)obj withUUID:(UUID *)uuid;
- (NSObject *) getObjWithUUID:(UUID *)uuid withType:(Class) aClass;
- (void) initWithLocations:(NSArray *)newLocations withUsers:(NSArray *)newUsers withMeetings:(NSArray *)newMeetings withRooms:(NSArray *)newRooms;
- (void) unswizzleGroup:(NSSet *)groupToUnswizzle;
- (NSSet *) getLocations;
- (NSSet *) getRooms; 
- (NSSet *) getUsers;
- (void) addActor:(Actor *)newActor;
- (void) addMeeting:(Meeting *)newMeeting;
- (void) removeActor:(Actor *)actorToRemove;
- (void) removeMeeting:(Meeting *)meetingToRemove;

+ (StateManager*)sharedInstance;

@property(nonatomic, retain)Meeting *meeting;
@property(nonatomic, retain)Location *location;
@property(nonatomic, retain)User *user;

@end
