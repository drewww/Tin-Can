//
//  ConnectionManager.m
//  TinCan
//
//  Created by Drew Harry on 7/16/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "ConnectionManager.h"
#import "StateManager.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Event.h"

static ConnectionManager *sharedInstance = nil;

@implementation ConnectionManager

#pragma mark --
#pragma mark class Instance methods
- (id) init {
    self = [super init];
    
    parser = [[[SBJSON alloc] init] retain];
   @synchronized(self) {
    eventListeners = [[NSMutableSet set] retain];
   }
    return self;
}


#pragma mark -
#pragma mark Connection Management

- (void) setLocation:(UUID *)newLocationUUID {
    if(locationUUID!=nil) [locationUUID release];
    
    locationUUID = newLocationUUID;
    [locationUUID retain];
    NSLog(@"Set local location: %@", locationUUID);
}

- (void) connect {
    if(locationUUID==nil) {
        NSLog(@"Must call setLocation before connecting.");
    }
    
    NSLog(@"logging in...");
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@%@", SERVER, PORT, @"/connect/login"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:locationUUID forKey:@"actorUUID"];    
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void) getState {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@%@", SERVER, PORT, @"/connect/state"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];   
}

- (void) startPersistentConnection {
 
    [self stopPersistentConnection];
    NSLog(@"/CONNECT/ING");
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@%@?actorUUID=%@", SERVER, PORT, @"/connect/", locationUUID]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    // hour long timeout, since this is the long-running connection.
    [request setTimeOutSeconds:3600];
    [request setDelegate:self];
    [request startAsynchronous];
    
    currentPersistentConnection = request;
    [currentPersistentConnection retain];
}

- (void) stopPersistentConnection {
    if(currentPersistentConnection != nil) {
        NSLog(@"releaseing connection");
        [currentPersistentConnection cancel];
        [currentPersistentConnection release];
    }
}   

- (void) requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"Request finished: %@", [request.url path]);
    
    NSString *path = [request.url path];
    
    // We should have some fancier way of figuring this out, but for now
    // just decide which request it is based on the url. This is really
    // fragile, but I'm not sure how to work around it.
    if([path rangeOfString:@"/connect/login"].location != NSNotFound) {
        NSLog(@"Login request successful.");
        
        Event *e = [[Event alloc] initWithType:kLOGIN_COMPLETE withLocal:true withParams:nil withResults:nil];                    
        [self publishEvent:e];

        // Start the persistent connection here.
        [self startPersistentConnection];
        
    } else if ([path rangeOfString:@"/connect/state"].location != NSNotFound) {
        NSLog(@"State request successful.");
        
        NSDictionary *result = [parser objectWithString:[request responseString] error:nil];
        
        
        NSArray *locations = [result objectForKey:@"locations"];
        NSArray *users = [result objectForKey:@"users"];
        NSArray *meetings = [result objectForKey:@"meetings"];
        NSArray *rooms = [result objectForKey:@"rooms"];
        
        [[StateManager sharedInstance] initWithLocations:locations
                                               withUsers:users
                                            withMeetings:meetings
                                               withRooms:rooms]; 
//        
        Event *e = [[Event alloc] initWithType:kGET_STATE_COMPLETE withLocal:true withParams:nil withResults:nil];                    
        [self publishEvent:e];
        NSLog(@"Done with GET_STATE");
    } else if ([path isEqualToString:@"/connect"]) {
        
        // Handle events being transmitted from an ending persistent connection.
        NSArray *result = [parser objectWithString:[request responseString] error:nil];
    
        NSLog(@"event results: %@", result);
    
        for(NSDictionary *eventDict in result) {
            Event *event = [[Event alloc] initFromDictionary:eventDict];
            [self dispatchEvent:event];
        }
        
        
        Event *e = [[Event alloc] initWithType:kCONNECT_COMPLETE withLocal:true withParams:nil withResults:nil];                    
        [self publishEvent:e];

        [self startPersistentConnection];
    }
}

- (void) requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"Request failed: %@", request.url);
}


#pragma mark -
#pragma mark Event Methods

- (void) dispatchEvent:(Event *)e {
    NSLog(@"DISPATCH: %@", e);
    StateManager *state = [StateManager sharedInstance];
        
    User *user;
    Meeting *meeting;
    Location *location;
    //Room *room;
    
    NSDictionary *results;
    
    switch(e.type) {
        case kADD_ACTOR_DEVICE:
            // Don't need to do anything here.
            break;
            
        case kNEW_USER:
            NSLog(@"NEW_USER");
            results = (NSDictionary *)[e.results objectForKey:@"user"];
            
            user = [[User alloc] initWithUUID:[results objectForKey:@"uuid"]
                                     withName:[results objectForKey:@"name"]
                             withLocationUUID:[results objectForKey:@"location"]];
            [user unswizzle];
        
            [state addActor:user];  
            NSLog(@"NEW_USER: %@", user);
            break;
            
        case kNEW_MEETING:
            NSLog(@"NEW_MEETING");
            results = [e.results objectForKey:@"meeting"];
            
            meeting = [[Meeting alloc] initWithUUID:[results objectForKey:@"uuid"]
                                          withTitle:[results objectForKey:@"title"]
                                       withRoomUUID:[results objectForKey:@"room"]];
            [meeting unswizzle];
            
            [state addMeeting:meeting];                                            
            NSLog(@"NEW_MEETING: %@", meeting);
            break;
            
        case kUSER_LEFT_LOCATION:
            
            location = (Location *)[state getObjWithUUID:[e.params objectForKey:@"location"]
                                              withType:[Meeting class]];
            user = (User *)[state getObjWithUUID:e.actorUUID withType:[User class]];
            
            [location userLeft:user];                  
            NSLog(@"USER_LEFT_LOCATION: %@ left %@", user, location);
            break;
            
        case kUSER_JOINED_LOCATION:
            location = (Location *)[state getObjWithUUID:[e.params objectForKey:@"location"]
                                              withType:[Meeting class]];
            
            user = (User *)[state getObjWithUUID:e.actorUUID withType:[User class]];
            
            [location userJoined:user];                  
            NSLog(@"USER_JOINED_LOCATION: %@ joined %@", user, location);
            break;
            
        case kLOCATION_LEFT_MEETING:
            meeting = (Meeting *)[state getObjWithUUID:e.meetingUUID withType:[Meeting class]];
            
            location = (Location *)[state getObjWithUUID:[e.params objectForKey:@"location"] withType:[Location class]];
            
            [meeting locationLeft:location];
            
            NSLog(@"LOCATION_LEFT_MEETING: %@ left %@", location, meeting);
            break;
            
            
        case kLOCATION_JOINED_MEETING:
            meeting = (Meeting *)[state getObjWithUUID:e.meetingUUID withType:[Meeting class]];
            
            location = (Location *)[state getObjWithUUID:[e.params objectForKey:@"location"] withType:[Location class]];
            
            [meeting locationLeft:location];
            
            NSLog(@"LOCATION_LEFT_MEETING: %@ left %@", location, meeting);
            break;            
            
        case kNEW_DEVICE:
            NSLog(@"received known event type, but am not doing anything about it");
            break;
            
        default:
            NSLog(@"Received an unknown event type: %d", e.type);
            break;
    }
}

- (void) addListener:(NSObject *)listener {
    [eventListeners addObject:listener];
    NSLog(@"Added listener. Total listeners: %@", eventListeners);
}

- (void) removeListener:(NSObject *)listener {
    [eventListeners removeObject:listener];
}

- (void) publishEvent:(Event *)e {

    NSLog(@"listeners: %@", eventListeners);
    for(NSObject *listener in [[eventListeners copy] autorelease]) {
        NSLog(@"publishing to: %@", listener);
        if([listener respondsToSelector:@selector(handleConnectionEvent:)])
            [listener handleConnectionEvent:e];
        else {
            NSLog(@"One of our event listeners didn't respond to 'handleConnectionEvent:'");
        }
    }
}


#pragma mark -
#pragma mark State Manipulation Methods

- (void) joinLocationWithUUID:(UUID *)locationUUID {
    
}

- (void) leaveLocationWithUUID:(UUID *)locationUUID {
    
}

- (void) joinRoomWithUUID:(UUID *)roomUUID {
    
}

- (void) leaveRoomWithUUID:(UUID *)locationUUID {
    
}

- (void) addLocationWithName:(NSString *)locationName {
    
}

#pragma mark -
#pragma mark Singleton methods

+ (ConnectionManager*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
            sharedInstance = [[ConnectionManager alloc] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end