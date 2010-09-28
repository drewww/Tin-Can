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
#import "StateManager.h"

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
    
    UIView *view;
}

- (id) initWithUUID:(UUID *)myUUID
           withText:(NSString *)myText
    withCreatorUUID:(UUID *)myCreatorUUID
          createdAt:(NSDate *)myCreatedAt
    withMeetingUUID:(UUID *)myMeetingUUID 
 withStartActorUUID:(UUID *)myStartActorUUID
  withStopActorUUID:(UUID *)myStopActorUUID
      withStartTime:(NSDate *)myStartTime
       withStopTime:(NSDate *)myStopTime
        withUIColor:(UIColor *)myColor;

- (void) setStatusWithString:(NSString *)stringStatus byActor:(Actor *)actor;

- (UIView *)getView;

- (NSComparisonResult) compareByStartTime:(Topic *)topic;


@property (readonly) NSString *text;

@property (nonatomic, retain) Actor *startActor;
@property (nonatomic, retain) Actor *stopActor;

@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSDate *stopTime;

@property (nonatomic, retain) UIColor *color;

@property (nonatomic, readonly) TopicStatus status;

@property (nonatomic, retain) UIView *view;


@end
