//
//  Location.h
//  TinCan
//
//  Created by Drew Harry on 7/15/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Actor.h"
#import "Meeting.h"
#import "User.h"

@class Meeting;
@class User;

@interface Location : Actor {
    Meeting *meeting;
    NSMutableSet *users;
}

- (id) initWithUUID:(NSString *)myUuid withName:(NSString *)myName withMeeting:(Meeting *)myMeeting withUsers:(NSMutableSet *)myUsers;
- (void) userJoined:(User *)theUser;
- (void) userLeft:(User *)theUser;
- (void) joinedMeeting:(Meeting *)theMeeting;
- (void) leftMeeting:(Meeting *)theMeeting;
- (BOOL) isInMeeting;
- (void) unswizzle;

@property(nonatomic, retain) NSSet *users;
@property(nonatomic, retain) Meeting *meeting;

@end
