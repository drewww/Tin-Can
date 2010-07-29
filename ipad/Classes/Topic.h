//
//  Topic.h
//  TinCan
//
//  Created by Drew Harry on 7/28/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseMeetingObject.h"
#import "User.h"
#import "Meeting.h"
#import "Actor.h"

typedef enum {
    kPAST,
    kCURRENT,
    kFUTURE
} TopicStatus;

@interface Topic : BaseMeetingObject {    
    NSString *text;
    
    TopicStatus status;
    
    NSDate *startTime;
    NSDate *stopTime;
    
    Actor *startActor;
    UUID *startActorUUID;
    
    Actor *stopActor;
    UUID *stopActorUUID;
    
    UIColor *color;
}

- (id) initWithUUID:(UUID *)myUUID
    withCreatorUUID:(UUID *)myCreatorUUID
          createdAt:(NSDate *)myCreatedAt
    withMeetingUUID:(UUID *)myMeetingUUID 
 withStartActorUUID:(UUID *)myStartActorUUID
  withStopActorUUID:(UUID *)myStopActorUUID
      withStartTime:(NSDate *)myStartTime
       withStopTime:(NSDate *)myStopTime
        withUIColor:(UIColor *)myColor;

@property (nonatomic, retain) Actor *startActor;
@property (nonatomic, retain) Actor *stopActor;

@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSDate *stopTime;

@property (nonatomic, retain) UIColor *color;

@property (nonatomic) TopicStatus status;


@end
