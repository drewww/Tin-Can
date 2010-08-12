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
#import "Topic.h"
#import "Task.h"

static ConnectionManager *sharedInstance = nil;

@implementation ConnectionManager

#pragma mark --
#pragma mark class Instance methods
- (id) init {
    self = [super init];
    
    parser = [[[SBJSON alloc] init] retain];
    
    //queue = [[[ASINetworkQueue alloc] init] retain];
    currentPersistentConnection = nil;
        
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
    
    StateManager *state = [StateManager sharedInstance];
    
    state.location = (Location *)[state getObjWithUUID:locationUUID withType:[Location class]];
    
    NSLog(@"Set local location: %@", locationUUID);
}

- (void) connect {
    if(locationUUID==nil) {
        NSLog(@"Must call setLocation before connecting.");
    }
    
    if(isConnected) {
        NSLog(@"Can't call connect once the client is already connected. Ignoring...");
        return;
    }

    // Setting this here so we don't have a problem where two rapid fire connect calls
    // go through, messing everything up. I catch it in the failure block 
    isConnected = YES;

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
 
    if(currentPersistentConnection != nil) {
        NSLog(@"currentConnection is not nil, but finished: %d", [currentPersistentConnection isFinished]);
        if(![currentPersistentConnection isFinished]) {
            // This happens WAY TOO OFTEN (like, every cycle). and represents a basic failing of the connection management
            // system that I haven't figured out yet. It does short-circuit the infinite connection problem,
            // though, so I'm leaving it like this for now. 
            NSLog(@"in startPersistentConnection, noticed that current connection isn't finished or is null, skipping");
            return;
        }
    }
    
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
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>> currentConnection: %@", currentPersistentConnection);

}

- (void) stopPersistentConnection {
    if(currentPersistentConnection != nil) {
        // Not totally sure about this - should stop actually stop? Need to diagnose this more closely.
        // Was having troubles where it would frequently cancel an active request.
        
//        NSLog(@"releasing connection");
//        [currentPersistentConnection cancel];
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
        NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<< request: %@", request);        
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
    NSError *error = [request error];
    NSLog(@"Request failed: %@ with error %@", request.url, error);
    
    // Make sure that if the login connect failed, we don't accidently block
    // all future attempts to connect.
    if([[request.url path] rangeOfString:@"/connect/login"].location != NSNotFound) {
        isConnected = NO;
    }
    
}


#pragma mark -
#pragma mark Event Methods

- (void) dispatchEvent:(Event *)e {
    NSLog(@"DISPATCH: %@", e);
    StateManager *state = [StateManager sharedInstance];
        
    User *user;
    Meeting *meeting;
    Location *location;
    Topic *topic;
    Task *task;
    Actor *actor;
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
            
            
            // Push the objective-c-ized object back into the event
            // so consumers of the event can get at it easily.
            [e.results setValue:user forKey:@"user"];
            
            NSLog(@"NEW_USER: %@", user);
            break;
            
        case kNEW_MEETING:
            NSLog(@"NEW_MEETING");
            results = [e.results objectForKey:@"meeting"];
            NSLog(@"results: %@", results);
            
            meeting = [[Meeting alloc] initWithUUID:[results objectForKey:@"uuid"]
                                          withTitle:[results objectForKey:@"title"]
                                       withRoomUUID:[results objectForKey:@"room"]
                                          startedAt:[NSDate dateWithTimeIntervalSince1970:[[results objectForKey:@"startedAt"] doubleValue]]];
            [meeting unswizzle];
            
            [state addMeeting:meeting];
            
            [e.results setValue:meeting forKey:@"meeting"];
            
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
            meeting = (Meeting *)[state getObjWithUUID:[e.params objectForKey:@"meeting"] withType:[Meeting class]];
            
            location = (Location *)[state getObjWithUUID:e.actorUUID withType:[Location class]];
            
            [meeting locationLeft:location];
            
            if(location.uuid == state.location.uuid) {
                state.meeting = nil;
            }
            
            
            NSLog(@"LOCATION_LEFT_MEETING: %@ left %@", location, meeting);
            break;
            
            
        case kLOCATION_JOINED_MEETING:
            meeting = (Meeting *)[state getObjWithUUID:[e.params objectForKey:@"meeting"] withType:[Meeting class]];
            
            location = (Location *)[state getObjWithUUID:e.actorUUID withType:[Location class]];
            
            [meeting locationLeft:location];
            
            // if this location is the local location, set the local meeting.
            if(location.uuid == state.location.uuid) {
                state.meeting = meeting;
            }
            
            NSLog(@"LOCATION_JOINED_MEETING: %@ joined %@", location, meeting);
            break;            
            
        case kNEW_TOPIC:
            results = (NSDictionary *)[e.results objectForKey:@"topic"];
            
            topic = [[Topic alloc] initWithUUID:[results objectForKey:@"uuid"]
                                       withText:[results objectForKey:@"text"]
                                withCreatorUUID:[results objectForKey:@"createdBy"]
                                      createdAt:[results objectForKey:@"createdAt"]
                                withMeetingUUID:[results objectForKey:@"meeting"]
                             withStartActorUUID:[results objectForKey:@"startActor"]
                              withStopActorUUID:[results objectForKey:@"stopActor"]
                                  withStartTime:[NSDate dateWithTimeIntervalSince1970:[[results objectForKey:@"startTime"] doubleValue]]
                                   withStopTime:[NSDate dateWithTimeIntervalSince1970:[[results objectForKey:@"stopTime"] doubleValue]]
                                    withUIColor:[UIColor blueColor]];
            
            // TODO hook up the color transmission. The problem is we need to decompose a hex color string
            // into RGB values that UIColor will accept. NBD, but a bit of an annoying dance and we'll
            // need to write a little function to do it.
            [topic unswizzle];
            
            [e.results setValue:topic forKey:@"topic"];

            break;
            
        case kUPDATE_TOPIC:
            topic = (Topic *)[state getObjWithUUID:[e.params objectForKey:@"topicUUID"] withType:[Topic class]];
            actor = (Actor *)[state getObjWithUUID:e.actorUUID withType:[Actor class]];
            
            NSString *status = [e.params objectForKey:@"status"];
            
            [topic setStatusWithString:status byActor:actor];
            
            break;
            
        
        case kNEW_TASK:
            results = (NSDictionary *)[e.results objectForKey:@"task"];
            
            NSDate *date;
            if([[results objectForKey:@"assignedAt"] isKindOfClass:[NSNull class]]) {
                date = nil;
            } else {
                date = [NSDate dateWithTimeIntervalSince1970:[[results objectForKey:@"assignedAt"] doubleValue]];
            }
            
            task = [[Task alloc] initWithUUID:[results objectForKey:@"uuid"]
                              withCreatorUUID:[results objectForKey:@"createdBy"]
                                    createdAt:[results objectForKey:@"createdAt"]
                              withMeetingUUID:[results objectForKey:@"meeting"]
                                     withText:[results objectForKey:@"text"]
                               assignedToUUID:[results objectForKey:@"assignedTo"]
                               assignedByUUID:[results objectForKey:@"assignedBy"]
                                   assignedAt:date];
            
            [task unswizzle];
            
            [e.results setValue:task forKey:@"task"];
            
            break;
        
        case kDELETE_TASK:
            task = (Task *)[state getObjWithUUID:[e.params objectForKey:@"taskUUID"] withType:[Task class]];
            meeting = task.meeting;
            [meeting removeTask:task];
            break;
            
        case kEDIT_TASK:
            task = (Task *)[state getObjWithUUID:[e.params objectForKey:@"taskUUID"] withType:[Task class]];
            NSString *text = [e.params objectForKey:@"text"];
            task.text = text;
            break;
            
        case kASSIGN_TASK:
            task = (Task *)[state getObjWithUUID:[e.params objectForKey:@"taskUUID"] withType:[Task class]];
            
            Actor *assignedBy = (Actor *)[state getObjWithUUID:e.actorUUID withType:[Actor class]];
            NSDate *assignedAt = [NSDate dateWithTimeIntervalSince1970:[[e.params objectForKey:@"assignedAt"] doubleValue]];
            
            if([e.params objectForKey:@"deassign"]) {
                // Do deassign logic.   
                [task deassignByActor:assignedBy atTime:assignedAt];
            } else {
                // Do assign logic.
                User *assignedTo = (User *)[state getObjWithUUID:[e.params objectForKey:@"assignedTo"] withType:[User class]];
                [task assignToUser:assignedTo byActor:assignedBy atTime:assignedAt];
            }
            break;
            
        case kEDIT_MEETING:
            meeting = (Meeting *)[state getObjWithUUID:[e.params objectForKey:@"meeting"] withType:[Meeting class]];
            NSString *title = [e.params objectForKey:@"title"];
            
            meeting.title = title;
            break;
        
        case kNEW_DEVICE:
            NSLog(@"received known event type, but am not doing anything about it");
            break;
            
        default:
            NSLog(@"Received an unknown event type: %d", e.type);
            break;
    }
    
    [self publishEvent:e];
}

- (void) addListener:(NSObject *)listener {
    [eventListeners addObject:listener];
    NSLog(@"Added listener. Total listeners: %@", eventListeners);
}

- (void) removeListener:(NSObject *)listener {
    [eventListeners removeObject:listener];
}

- (void) publishEvent:(Event *)e {
    NSLog(@"publishing event with type %d", e.type);

    for(NSObject *listener in [[eventListeners copy] autorelease]) {
        if([listener respondsToSelector:@selector(handleConnectionEvent:)])
            [listener handleConnectionEvent:e];
        else {
            NSLog(@"One of our event listeners didn't respond to 'handleConnectionEvent:'");
        }
    }
}


#pragma mark -
#pragma mark State Manipulation Methods

- (void) joinRoomWithUUID:(UUID *)roomUUID {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@%@", SERVER, PORT, @"/rooms/join"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:roomUUID forKey:@"roomUUID"];    
    [request setDelegate:self];
    [request startAsynchronous]; 
}

- (void) leaveRoomWithUUID {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@%@", SERVER, PORT, @"/rooms/leave"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];     
}

- (void) addLocationWithName:(NSString *)locationName {
    NSLog(@"ADD LOCATION WITH NAME IS NOT IMPLEMENTED.");  
}

- (void) assignTask:(Task *)theTask toUser:(User *)theUser {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@%@", SERVER, PORT, @"/tasks/assign"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:theTask.uuid forKey:@"taskUUID"];    
    [request setPostValue:theUser.uuid forKey:@"assignedToUUID"];    
    [request setDelegate:self];
    [request startAsynchronous];     
}

- (void) deassignTask:(Task *)theTask {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@%@", SERVER, PORT, @"/tasks/assign"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:theTask.uuid forKey:@"taskUUID"];    
    [request setPostValue:@"1" forKey:@"deassign"];    
    [request setDelegate:self];
    [request startAsynchronous];         
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