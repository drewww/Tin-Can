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
#import "UIColor+Util.h"

static ConnectionManager *sharedInstance = nil;
static NSString *selectedServer = nil;

@implementation ConnectionManager

@synthesize serverReachability;
@synthesize server;

#pragma mark --
#pragma mark class Instance methods
- (id) initWithServer:(NSString *)theServer {
    self = [super init];
    
    parser = [[[SBJSON alloc] init] retain];
    
    //queue = [[[ASINetworkQueue alloc] init] retain];
    currentPersistentConnection = nil;
    
    server = theServer;

    self.serverReachability = [Reachability reachabilityWithHostName:server];
    [self.serverReachability startNotifer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                       selector:@selector(handleNotification:)
                                           name:kReachabilityChangedNotification
                                         object:nil];
    
    @synchronized(self) {
        eventListeners = [[NSMutableSet set] retain];
    }
    
    
    
    return self;
}


#pragma mark -
#pragma mark Connection Management

- (void) handleNotification:(NSNotification *)notification {
    if([notification name]==kReachabilityChangedNotification) {
        NSLog(@"Connection state changed, dispatching a message to that effect.");
        Event *e = [[Event alloc] initWithType:kCONNECTION_STATE_CHANGED withLocal:true withParams:nil withResults:nil];                    
        [self publishEvent:e];
    }
}

- (void) setLocation:(UUID *)newLocationUUID {
    if(locationUUID!=nil) [locationUUID release];
    
    locationUUID = newLocationUUID;
    [locationUUID retain];
    
    StateManager *state = [StateManager sharedInstance];
    
    state.location = (Location *)[state getObjWithUUID:locationUUID withType:[Location class]];
    
    NSLog(@"Set local location: %@", locationUUID);
}

- (void) setUser:(UUID *)newUserUUID {
    if(userUUID!=nil) [userUUID release];
    
    userUUID = newUserUUID;
    [userUUID retain];
    
    StateManager *state = [StateManager sharedInstance];
    
    state.user = (User *)[state getObjWithUUID:userUUID withType:[User class]];
    
    NSLog(@"Set local user: %@", userUUID);    
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

    // Do a bit of logic here to decide if we're going to connect with the location as the
    // actor or the user. Basically, user is going to take precedence because it's more specific
    // but we can fall back on the locationUUID. 
    
    UUID *actorUUID = nil;
    
    if(userUUID != nil) actorUUID = userUUID;
    else actorUUID = locationUUID;
    
    if(actorUUID == nil) {
        NSLog(@"Neither user or actor was specificed before attempting to connect. Failing.");
        return;
    }
    
    NSLog(@"logging in...");
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@%@", server, PORT, @"/connect/login"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:actorUUID forKey:@"actorUUID"];    
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void) getState {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@%@", server, PORT, @"/connect/state"]];
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
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@%@?actorUUID=%@", server, PORT, @"/connect/", locationUUID]];
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
    
    if([serverReachability currentReachabilityStatus]!=NotReachable) {
        // This means the connection is alive, so the server must be down.
        // Dispatch a message to that effect.
        
        // (I'm not sure I need to check reachability here - depends on whether or not we 
        //  expect downstream clients of this to be checking reachability first or not.)
        Event *e = [[Event alloc] initWithType:kCONNECTION_REQUEST_FAILED withLocal:true withParams:nil withResults:nil];                    
        [self publishEvent:e];        
    }
    
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
                                              withType:[Location class]];
            user = (User *)[state getObjWithUUID:e.actorUUID withType:[User class]];
            
            [location userLeft:user];                  
            
            if(user.uuid = state.user.uuid) {
                state.location = nil;
            }            
            
            NSLog(@"USER_LEFT_LOCATION: %@ left %@", user, location);
            break;
            
        case kUSER_JOINED_LOCATION:
            location = (Location *)[state getObjWithUUID:[e.params objectForKey:@"location"]
                                              withType:[Location class]];
            
            user = (User *)[state getObjWithUUID:e.actorUUID withType:[User class]];
            
            
            NSLog(@"USER JOINING %@ with UUID %@", user, user.uuid);
            
            NSLog(@"dumping known user list");
            
            
            
            for (User *u in [[StateManager sharedInstance] getUsers]) {
                NSLog(@"%@", u);
            }
            
            [location userJoined:user]; 
            
            if(user.uuid = state.user.uuid) {
                state.location = location;
            }
            
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
            
            [meeting locationJoined:location];
            
            // if this location is the local location, set the local meeting.
            if(location.uuid == state.location.uuid) {
                state.meeting = meeting;
            }
            
            NSLog(@"LOCATION_JOINED_MEETING: %@ joined %@", location, meeting);
            break;            
            
        case kNEW_TOPIC:
            results = (NSDictionary *)[e.results objectForKey:@"topic"];
            
            NSDate *startTime;
            NSDate *stopTime;
            
            if([[results objectForKey:@"startTime"] isKindOfClass:[NSNull class]]) {
                startTime = nil; 
            } else {
                startTime = [NSDate dateWithTimeIntervalSince1970:[[results objectForKey:@"startTime"] doubleValue]];
            }

            if([[results objectForKey:@"stopTime"] isKindOfClass:[NSNull class]]) {
                stopTime = nil; 
            } else {
                stopTime = [NSDate dateWithTimeIntervalSince1970:[[results objectForKey:@"stopTime"] doubleValue]];
            }
            
            topic = [[Topic alloc] initWithUUID:[results objectForKey:@"uuid"]
                                       withText:[results objectForKey:@"text"]
                                withCreatorUUID:[results objectForKey:@"createdBy"]
                                      createdAt:[NSDate dateWithTimeIntervalSince1970:[[results objectForKey:@"createdAt"] doubleValue]]
                                     withStatus:[results objectForKey:@"status"]
                                withMeetingUUID:[results objectForKey:@"meeting"]
                             withStartActorUUID:[results objectForKey:@"startActor"]
                              withStopActorUUID:[results objectForKey:@"stopActor"]
                                  withStartTime:startTime
                                   withStopTime:stopTime
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
                                    createdAt:[NSDate dateWithTimeIntervalSince1970:[[results objectForKey:@"createdAt"] doubleValue]]
                              withMeetingUUID:[results objectForKey:@"meeting"]
                                     withText:[results objectForKey:@"text"]
                               assignedToUUID:[results objectForKey:@"assignedTo"]
                               assignedByUUID:[results objectForKey:@"assignedBy"]
                                   assignedAt:date
                                    withColor:[UIColor colorWithHexString:[results objectForKey:@"color"]]];
            
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

            // Okay, so this is a bit of a tricky thing. This is not being handled here because when
            // we go to deassign, we need to send a reference to the taskContainer to the taskView so
            // it knows who to attach to. This is BAD FORM and shouldn't be happening, but I can't come
            // up with a nicer way to structure it right now. 
            
            // So yeah, that's why there's nothing here. It's all handled in MeetingViewController's
            // event handler code.
            
            break;
            
        case kEDIT_MEETING:
            meeting = (Meeting *)[state getObjWithUUID:[e.params objectForKey:@"meeting"] withType:[Meeting class]];
            NSString *title = [e.params objectForKey:@"title"];
            
            meeting.title = title;
            break;
        case kUPDATE_STATUS:
            NSLog(@"handling status update!");
            actor = (Actor *)[state getObjWithUUID:e.actorUUID withType:[Actor class]];
            
            if([[e.params objectForKey:@"time"] isKindOfClass:[NSNull class]]) {
                date = nil; 
            } else {
                date = [NSDate dateWithTimeIntervalSince1970:[[e.params objectForKey:@"time"] doubleValue]];
            }
            
            [actor setStatus:[e.params objectForKey:@"status"] atDate:date];
            
            NSLog(@"actor status after update: %@ at time %@", actor.status, actor.statusDate);
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
    NSLog(@"removing listener: %@", listener);
    [eventListeners removeObject:listener];
    NSLog(@"remaining listeners: %@", eventListeners);
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

- (void) joinLocation:(Location *)locationToJoin withUser:(User *)userJoiningLocation {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@%@", server, PORT, @"/locations/join"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:locationToJoin.uuid forKey:@"locationUUID"];    
    [request setPostValue:userJoiningLocation.uuid forKey:@"userUUID"];    
    [request setDelegate:self];
    [request startAsynchronous];    
}

- (void) joinRoomWithUUID:(UUID *)roomUUID {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@%@", server, PORT, @"/rooms/join"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:roomUUID forKey:@"roomUUID"];    
    [request setDelegate:self];
    [request startAsynchronous]; 
}

- (void) leaveRoomWithUUID {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@%@", server, PORT, @"/rooms/leave"]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startAsynchronous];     
}

- (void) addLocationWithName:(NSString *)locationName {
    NSLog(@"ADD LOCATION WITH NAME IS NOT IMPLEMENTED.");  
}

- (void) assignTask:(Task *)theTask toUser:(User *)theUser {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@%@", server, PORT, @"/tasks/assign"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:theTask.uuid forKey:@"taskUUID"];    
    [request setPostValue:theUser.uuid forKey:@"assignedToUUID"];    
    [request setDelegate:self];
    [request startAsynchronous];     
}

- (void) deassignTask:(Task *)theTask {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@%@", server, PORT, @"/tasks/assign"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:theTask.uuid forKey:@"taskUUID"];    
    [request setPostValue:@"1" forKey:@"deassign"];    
    [request setDelegate:self];
    [request startAsynchronous];         
}

- (void) addTaskWithText:(NSString *)newTaskText isInPool:(bool)isInPool isCreatedBy:(UUID *)createdBy isAssignedBy:(UUID *)assignedBy {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@%@", server, PORT, @"/tasks/add"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:newTaskText forKey:@"text"];    
    
    NSString *val;
    
    if(isInPool) val = @"1";
    else val = @"0";
    
    [request setPostValue:val forKey:@"createInPool"];
    
    if(createdBy != nil) {
        [request setPostValue:createdBy forKey:@"createdBy"];
    }
    
    if(assignedBy != nil) {
        [request setPostValue:assignedBy forKey:@"assignedBy"];
    }
    NSLog(@" sending new task request with createdBy: %@ and assignedBy: %@", createdBy, assignedBy);
    
    // Per the classroom "idea" model, don't move the idea over, just create a new one
    // that is unassigned.
    Topic *currentTopic = [[StateManager sharedInstance].meeting getCurrentTopic];
    UIColor *theColor = nil;
    if (currentTopic != nil) {
        theColor = currentTopic.color;
    }
    
    if(theColor != nil) {
        [request setPostValue:[theColor toHexString] forKey:@"color"];
    }

    [request setDelegate:self];
    [request startAsynchronous];
}

- (void) deleteTask:(Task *)taskToDelete {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@%@", server, PORT, @"/tasks/delete"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:taskToDelete.uuid forKey:@"taskUUID"];    
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void) updateTopic:(Topic *)theTopic withStatus:(TopicStatus)theStatus {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@%@", server, PORT, @"/topics/update"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:theTopic.uuid forKey:@"topicUUID"];
    
    // I hate doing this, in case the enum changes, but I haven't seen a good way around it yet.
    NSArray *enumMapping = [[NSArray arrayWithObjects:@"PAST", @"CURRENT", @"FUTURE", nil] retain];
    
    [request setPostValue:[enumMapping objectAtIndex:theStatus]  forKey:@"status"];    
    [request setDelegate:self];
    [request startAsynchronous]; 
    
    [enumMapping release];
}

- (void) restartTopic:(Topic *)theTopic {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@%@", server, PORT, @"/topics/restart"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:theTopic.uuid forKey:@"topicUUID"];    
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void) addTopicWithText:(NSString *)newTopicText {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@%@", server, PORT, @"/topics/add"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:newTopicText forKey:@"text"];    
    [request setDelegate:self];
    [request startAsynchronous];
}



#pragma mark -
#pragma mark Singleton methods

+ (ConnectionManager*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil) {
            if(selectedServer == nil) {
                sharedInstance = [[ConnectionManager alloc] initWithServer:SERVER];
            } else {
                sharedInstance = [[ConnectionManager alloc] initWithServer:selectedServer];
            }
        }
    }
    return sharedInstance;
}

+ (void) setServer:(NSString *)server {
    selectedServer = server;
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