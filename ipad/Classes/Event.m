//
//  Event.m
//  TinCan
//
//  Created by Drew Harry on 7/16/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "Event.h"



@implementation Event


@synthesize type;
@synthesize actorUUID;
@synthesize meetingUUID;
@synthesize params;
@synthesize results;

- (id) initEventFromDictionary:(NSDictionary *)eventDictionary {
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
                                                                    kLOCATION_LEFT_ROOM,
                                                                    kNEW_DEVICE,
                                                                    kADD_ACTOR_DEVICE,
                                                                    kNEW_LOCATION,
                                                                    @"NEW_MEETING",
                                                                    @"JOINED_MEETING",
                                                                    @"USER_JOINED_LOCATION",
                                                                    @"USER_LEFT_LOCATION",
                                                                    @"NEW_USER",
                                                                    @"LOCATION_JOINED_MEETING",
                                                                    @"LOCATION_LEFT_ROOM",
                                                                    @"NEW_DEVICE",
                                                                    @"ADD_ACTOR_DEVICE",
                                                                    @"NEW_LOCATION", nil] autorelease];
    
    
    self.type = (EventType)[enumMapping objectForKey:stringType];
    
    self.meetingUUID = [eventDictionary objectForKey:@"meetingUUID"];
    self.actorUUID = [eventDictionary objectForKey:@"actorUUID"];
    
    self.params = [eventDictionary objectForKey:@"params"];
    self.results = [eventDictionary objectForKey:@"results"];
    
    return self;
}


@end
