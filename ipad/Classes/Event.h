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
    kLEFT_ROOM,
    kUSER_JOINED_LOCATION,
    kUSER_LEFT_LOCATION,
    kNEW_USER,
    kLOCATION_JOINED_MEETING,
    kLOCATION_LEFT_ROOM,
    kNEW_DEVICE,
    kADD_ACTOR_DEVICE,
    kNEW_LOCATION
} EventType;

@interface Event : NSObject {
    EventType type;
    UUID *actorUUID;
    UUID *meetingUUID;
    
    NSDictionary *params;
    NSDictionary *results;
}

- (id) initEventFromDictionary:(NSDictionary *)eventDictionary;


@property(nonatomic) EventType type;
@property(nonatomic, retain) UUID *actorUUID;
@property(nonatomic, retain) UUID *meetingUUID;
@property(nonatomic, retain) NSDictionary *params;
@property(nonatomic, retain) NSDictionary *results;


@end
