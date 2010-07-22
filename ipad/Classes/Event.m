//
//  Event.m
//  TinCan
//
//  Created by Drew Harry on 7/16/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "Event.h"



@implementation Event


@synthesize uuid;
@synthesize type;
@synthesize actorUUID;
@synthesize meetingUUID;
@synthesize params;
@synthesize results;
@synthesize localEvent;

- (id) initFromDictionary:(NSDictionary *)eventDictionary {
    self = [super init];
    
    // unpack the type into an enum.
    NSString *stringType = [eventDictionary objectForKey:@"eventType"];
    
    NSDictionary *enumMapping = [[NSDictionary dictionaryWithObjectsAndKeys:kNEW_MEETING,
                                                                    kJOINED_MEETING,
                                                                    kLEFT_ROOM,
                                                                    kUSER_JOINED_LOCATION,
                                                                    kUSER_LEFT_LOCATION,
                                                                    kNEW_USER,
                                                                    kLOCATION_JOINED_MEETING,
                                                                    kLOCATION_LEFT_MEETING,
                                                                    kNEW_DEVICE,
                                                                    kADD_ACTOR_DEVICE,
                                                                    kNEW_LOCATION,
                                                                    @"NEW_MEETING",
                                                                    @"JOINED_MEETING",
                                                                    @"USER_JOINED_LOCATION",
                                                                    @"USER_LEFT_LOCATION",
                                                                    @"NEW_USER",
                                                                    @"LOCATION_JOINED_MEETING",
                                                                    @"LOCATION_LEFT_MEETING",
                                                                    @"NEW_DEVICE",
                                                                    @"ADD_ACTOR_DEVICE",
                                                                    @"NEW_LOCATION", nil] retain];
    
    
    self.type = (EventType)[enumMapping objectForKey:stringType];
    
    self.uuid = [eventDictionary objectForKey:@"uuid"];
    
    self.meetingUUID = [eventDictionary objectForKey:@"meetingUUID"];
    self.actorUUID = [eventDictionary objectForKey:@"actorUUID"];
    
    self.params = [eventDictionary objectForKey:@"params"];
    self.results = [eventDictionary objectForKey:@"results"];
    
    
    localEvent = false;
    
    [enumMapping release];
    
    return self;
}

// This one is just sugar for the main one. 
- (id) initWithType:(EventType)myType withLocal:(BOOL)isLocalEvent withParams:(NSDictionary *)myParams
        withResults:(NSDictionary *)myResults {
    return [self initWithType:myType withUUID:nil withLocal:isLocalEvent withParams:myParams withResults:myResults];
}

- (id) initWithType:(EventType)myType withUUID:(UUID *)myUUID withLocal:(BOOL)isLocalEvent withParams:(NSDictionary *)myParams
withResults:(NSDictionary *)myResults {
    
    self = [super init];
    
    self.type = myType;
    
    localEvent = isLocalEvent;
    
    self.uuid = myUUID;
    
    // TODO Should these be set to the local meeting? Or just assume that clients
    // won't look too closely at these? 
    self.meetingUUID = nil;
    self.actorUUID = nil;
    
    self.params = myParams;
    self.results = myResults;
    
    return self;
}

- (NSString *) description {
    if(self.uuid!=nil && ![self.uuid isKindOfClass:[NSNull class]]) {
        return [NSString stringWithFormat:@"[event.%@ %d meet:%@ actor:%@ params:%d results:%d]", [self.uuid substringToIndex:6],
                self.type, self.meetingUUID, self.actorUUID, [self.params count], [self.results count]];
    }
    else {
        NSLog(@"printing without");
        return [NSString stringWithFormat:@"[event.000000 %d meet:%@ actor:%@ params:%d results:%d]", [self.uuid substringToIndex:6],
                self.type, self.meetingUUID, self.actorUUID, [self.params count], [self.results count]];
    }
}

@end
