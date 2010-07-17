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
    
    eventListeners = [NSMutableSet set];
    
    return self;
}


#pragma mark -
#pragma mark Connection Management

- (void) setLocation:(UUID *)newLocationUUID {
    
    locationUUID = newLocationUUID;
    [locationUUID retain];
    NSLog(@"Set local location: %@", locationUUID);
}

- (void) connect {
    if(locationUUID==nil) {
        NSLog(@"Must call setLocation before connecting.");
    }
    
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
        [currentPersistentConnection cancel];
        [currentPersistentConnection release];
    }
}   

- (void) requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"Request finished: %@", request.url);
    
    NSString *path = [request.url path];
    
    // We should have some fancier way of figuring this out, but for now
    // just decide which request it is based on the url.
    if([path rangeOfString:@"/connect/login"].location != NSNotFound) {
        NSLog(@"Login request successful.");
        
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
    } else if ([path isEqualToString:@"/connect/"]) {
        
        // Handle events being transmitted from an ending persistent connection.
        NSArray *result = [parser objectWithString:[request responseString] error:nil];
    
        NSLog(@"event results: %@", result);
    
        for(NSDictionary *eventDict in result) {
            Event *event = [[Event alloc] initEventFromDictionary:eventDict];
            NSLog(@"event: %@", event);
        }
        
        
        
        
        [self startPersistentConnection];
    }
}

- (void) requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"Request failed: %@", request.url);
}


#pragma mark -
#pragma mark Event Methods

- (void) dispatchEvent:(Event *)e {

}

- (void) addListener:(NSObject *)listener {
    [eventListeners addObject:listener];
}

- (void) removeListener:(NSObject *)listener {
    [eventListeners removeObject:listener];
}

- (void) publishEvent:(Event *)e {
    
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