//
//  Topic.m
//  TinCan
//
//  Created by Drew Harry on 7/28/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "Topic.h"
#import "TopicView.h"



@implementation Topic

@synthesize text;
@synthesize startActor;
@synthesize stopActor;

@synthesize startTime;
@synthesize stopTime;

@synthesize color;

@synthesize status;

@synthesize view;

- (id) initWithUUID:(UUID *)myUUID
           withText:(NSString *)myText
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
    
    self.startTime = myStartTime;
    self.stopTime = myStopTime;
    self.color = myColor;
    
    text = myText;
    
    // How does this actually get set from the server? Worried about this
    // not being properly connected.
    status = kFUTURE;
    
    return self;
}



- (void) setStatusWithString:(NSString *)stringStatus byActor:(Actor *)actor{
    // We need to convert the string (which is how it's represented on the server) to an enum
    // (which is how it's represented here. This is a little annoying. We'll fake it by
    // doing lookup against a list. This list should probably be static on the object, but I'm 
    // not 100% sure how to do that. 
    NSArray *enumMapping = [[NSArray arrayWithObjects:@"PAST", @"CURRENT", @"FUTURE", nil] retain];
    
    TopicStatus newStatus = (TopicStatus)[enumMapping indexOfObject:stringStatus];
    
    // Manage the logic around storing actors on state change.
    if(status==kFUTURE && newStatus==kCURRENT) {
        self.startActor = actor;
        self.startTime = [NSDate date];
    } else if (status==kCURRENT && newStatus == kFUTURE) {
        self.stopActor = actor;
        self.stopTime = [NSDate date];
    }
    
    status = newStatus;
    
    [enumMapping release];
}


- (UIView *)getView {
    
    if(view==nil) {
        // construct a new TaskView
        view = [[TopicView alloc] initWithTopic:self];
    }
    
    // return the current view
    return view;
}


- (void) unswizzle {
    [super unswizzle];
    
    if(startActorUUID!=nil && ![startActorUUID isKindOfClass:[NSNull class]]) {
        self.startActor = (Actor *)[[StateManager sharedInstance] getObjWithUUID:startActorUUID
                                                                        withType:[Actor class]];
    }

    if(stopActorUUID!=nil && ![stopActorUUID isKindOfClass:[NSNull class]]) {
        self.stopActor = (Actor *)[[StateManager sharedInstance] getObjWithUUID:stopActorUUID
                                                                        withType:[Actor class]];
    }
    
    [self.meeting addTopic:self];
}

- (NSString *)description {
        return [NSString stringWithFormat:@"[topic.%@ %@ started:%@ stopped:%@]", [self.uuid substringToIndex:6],
                self.text, self.startTime, self.stopTime];
}

@end
