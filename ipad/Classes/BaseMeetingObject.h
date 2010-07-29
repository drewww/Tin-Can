//
//  BaseMeetingObject.h
//  TinCan
//
//  Created by Drew Harry on 7/28/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynchronizedObject.h"
#import "Actor.h"
#import "Meeting.h"

@interface BaseMeetingObject : SynchronizedObject {
    User *creator;
    UUID *creatorUUID;
    
    Meeting *meeting;
    UUID *meetingUUID;
    
    NSDate *createdAt;
}

- (id) initWithUUID:(UUID *)myUUID withCreatorUUID:(UUID *)myCreatorUUID withMeetingUUID:(UUID *)myMeetingUUID
          createdAt:(NSDate *)myCreatedAt;

- (void) unswizzle;

@property (nonatomic, retain) User *creator;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic, retain) Meeting *meeting;

@end
