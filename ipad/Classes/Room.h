//
//  Room.h
//  TinCan
//
//  Created by Drew Harry on 7/15/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynchronizedObject.h"
#import "Meeting.h"

@class Meeting;

@interface Room : SynchronizedObject {
    Meeting *currentMeeting;
    NSString *name;
}

- (id) initWithUUID:(NSString *)myUuid withName:(NSString *)myName;

- (void) setMeeting:(Meeting *)myMeeting;
- (void) unswizzle;

@property(nonatomic, retain) Meeting *currentMeeting;
@property(nonatomic, retain) NSString *name;

@end
