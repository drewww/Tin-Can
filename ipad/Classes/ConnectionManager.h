//
//  ConnectionManager.h
//  TinCan
//
//  Created by Drew Harry on 7/16/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "SBJSON.h"
#import "tincan.h"
#import "Event.h"


@interface ConnectionManager : NSObject {
    UUID *locationUUID;
    
    // This may be converted to a delegate structure.
    // The tradeoff seems to be that delegates are
    // cleaner and easier to dispatch events to, but
    // you can only have one delegate for a class for
    // those mechanics to work. So if it turns we only
    // ever have one, we can switch to a delegate
    // structure.
    NSMutableSet *eventListeners;
    
    BOOL isConnected;
    
    
    ASIHTTPRequest *currentPersistentConnection;
    
    SBJSON *parser;
}

#pragma mark -
#pragma mark Connection Management

- (void) setLocation:(UUID *)newLocationUUID;
- (void) connect;

- (void) getState;

- (void) startPersistentConnection;
- (void) stopPersistentConnection;

- (void) requestFinished:(ASIHTTPRequest *)request;
- (void) requestFailed:(ASIHTTPRequest *)request;


#pragma mark -
#pragma mark Event Methods

- (void) dispatchEvent:(Event *)e;

- (void) addListener:(NSObject *)listener;
- (void) removeListener:(NSObject *)listener;

- (void) publishEvent:(Event *)e;



#pragma mark -
#pragma mark State Manipulation Methods

- (void) joinLocationWithUUID:(UUID *)locationUUID;
- (void) leaveLocationWithUUID:(UUID *)locationUUID;

- (void) joinRoomWithUUID:(UUID *)roomUUID;
- (void) leaveRoomWithUUID:(UUID *)locationUUID;

- (void) addLocationWithName:(NSString *)locationName;

@end
