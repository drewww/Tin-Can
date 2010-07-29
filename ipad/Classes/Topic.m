//
//  Topic.m
//  TinCan
//
//  Created by Drew Harry on 7/28/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "Topic.h"
#import "StateManager.h"


@implementation Topic

@synthesize startActor;
@synthesize stopActor;

@synthesize startTime;
@synthesize stopTime;

@synthesize color;

@synthesize status;

- (id) initWithUUID:(UUID *)myUUID
    withCreatorUUID:(UUID *)myCreatorUUID
          createdAt:(NSDate *)myCreatedAt
    withMeetingUUID:(UUID *)myMeetingUUID 
 withStartActorUUID:(UUID *)myStartActorUUID
  withStopActorUUID:(UUID *)myStopActorUUID
      withStartTime:(NSDate *)myStartTime
       withStopTime:(NSDate *)myStopTime
        withUIColor:(UIColor *)myColor
{
    self = [super initWithUUID:myUUID withCreatorUUID:myCreatorUUID withMeetingUUID:myMeetingUUID
                     createdAt:myCreatedAt];
    
    startActorUUID = myStartActorUUID;
    stopActorUUID = myStopActorUUID;
    
    self.startTime = startTime;
    self.stopTime = stopTime;
    self.color = myColor;
    
    return self;
}

- (void) unswizzle {
    if(startActorUUID!=nil && ![startActorUUID isKindOfClass:[NSNull class]]) {
        self.startActor = (Actor *)[[StateManager sharedInstance] getObjWithUUID:startActorUUID
                                                                        withType:[Actor class]];
    }

    if(stopActorUUID!=nil && ![stopActorUUID isKindOfClass:[NSNull class]]) {
        self.stopActor = (Actor *)[[StateManager sharedInstance] getObjWithUUID:stopActorUUID
                                                                        withType:[Actor class]];
    }
        
}

@end
