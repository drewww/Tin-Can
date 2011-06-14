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
@class Task;
@class Topic;

@interface Meeting : SynchronizedObject {
    Room *room;
    UUID *roomUUID;
    
    NSString *title;
    
    NSMutableSet *allParticipants;
    NSMutableSet *currentParticipants;
    NSMutableSet *locations;
    
    NSMutableSet *tasks;
    NSMutableSet *topics;
    
    NSDate *startedAt;
}

- (id) initWithUUID:(UUID *)myUuid withTitle:(NSString *)myTitle withRoomUUID:(UUID *)myRoomUUID startedAt:(NSDate *)myStartedAt;

- (void) userJoined:(User *)theUser theLocation:(Location *)theLocation;
- (void) userLeft:(User *)theUser theLocation:(Location *)theLocation;

- (void) locationJoined:(Location *)theLocation;
- (void) locationLeft:(Location *)theLocation;

- (void) addTask:(id)newTask;
- (void) removeTask:(id)removeTask;

- (void) addTopic:(id)newTopic;
- (void) removeTopic:(id)removeTopic;

- (NSSet *) getUnassignedTasks;

- (Topic *) getCurrentTopic;
- (NSSet *) getUpcomingTopics;

- (void) unswizzle;


@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) Room *room;
@property(nonatomic, retain) NSMutableSet *locations;
@property(nonatomic, retain) NSDate *startedAt;

@property(readonly) NSMutableSet *allParticipants;
@property(readonly) NSMutableSet *tasks;
@property(readonly) NSMutableSet *topics;
@property(readonly) NSMutableSet *currentParticipants;

@end
