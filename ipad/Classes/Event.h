//
//  Event.h
//  TinCan
//
//  Created by Drew Harry on 7/16/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tincan.h"


typedef enum {
    kNEW_MEETING,
    kJOINED_MEETING,
    kUSER_JOINED_LOCATION,
    kUSER_LEFT_LOCATION,
    kNEW_USER,
    kLOCATION_JOINED_MEETING,
    kLOCATION_LEFT_MEETING,
    kNEW_DEVICE,
    kADD_ACTOR_DEVICE,
    kNEW_LOCATION,
    kUPDATE_STATUS,
    kTHUMBS_UP,
    
    kNEW_TOPIC,
    kDELETE_TOPIC,
    kUPDATE_TOPIC,
    kSET_TOPIC_LIST,
    
    kNEW_TASK,
    kDELETE_TASK,
    kEDIT_TASK,
    kASSIGN_TASK,
    kLIKE_TASK,
    
    kEDIT_MEETING,
    
    // These are the internal events that ConnectionManager generates.
    kGET_STATE_COMPLETE,
    kNEW_USER_COMPLETE,
    kLEAVE_ROOM_COMPLETE,
    kJOIN_ROOM_COMPLETE,
    kLOGIN_COMPLETE,
    kCONNECT_COMPLETE,
    
    // Connection status events
    kCONNECTION_STATE_CHANGED,
    kCONNECTION_REQUEST_FAILED
} EventType;

@interface Event : NSObject {
    EventType type;
    UUID *uuid;
    UUID *actorUUID;
    UUID *meetingUUID;
    
    BOOL localEvent;
    
    NSDate *timestamp;
    
    NSDictionary *params;
    NSDictionary *results;
}

- (id) initFromDictionary:(NSDictionary *)eventDictionary;
- (id) initWithType:(EventType)myType withUUID:(UUID *)myUUID withLocal:(BOOL)isLocalEvent
         withParams:(NSDictionary *)myParams withResults:(NSDictionary *)myResults;
- (id) initWithType:(EventType)myType withLocal:(BOOL)isLocalEvent withParams:(NSDictionary *)myParams withResults:(NSDictionary *)results;

@property(nonatomic) EventType type;
@property(nonatomic) BOOL localEvent;

@property(nonatomic, retain) UUID *uuid;

@property(nonatomic, retain) UUID *actorUUID;
@property(nonatomic, retain) UUID *meetingUUID;
@property(nonatomic, retain) NSDictionary *params;
@property(nonatomic, retain) NSDictionary *results;

@property(nonatomic, retain) NSDate *timestamp;

@end
