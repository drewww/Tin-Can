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
#import "Task.h"
#import "Topic.h"
#import "Reachability.h"

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
    
    Reachability *serverReachability;
    
    NSString *server;
 }


- (id) initWithServer:(NSString *)theServer;

#pragma mark -
#pragma mark Properties

@property (nonatomic, retain) Reachability *serverReachability;
@property (nonatomic, readonly) NSString *server;

#pragma mark -
#pragma mark Connection Management

- (void) handleNotification:(NSNotification *)notification;

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

- (void) joinRoomWithUUID:(UUID *)roomUUID;
//- (void) leaveRoomWithUUID:(UUID *)roomUUID;

- (void) addLocationWithName:(NSString *)locationName;

- (void) assignTask:(Task *)theTask toUser:(User *)theUser;
- (void) deassignTask:(Task *)theTask;
- (void) addTaskWithText:(NSString *)newTaskText;

- (void) updateTopic:(Topic *)theTopic withStatus:(TopicStatus)theStatus;
- (void) restartTopic:(Topic *)theTopic;
- (void) addTopicWithText:(NSString *)newTopicText;


#pragma mark -
#pragma mark Static Fields

+ (ConnectionManager*)sharedInstance;
+ (void) setServer:(NSString *)server;

@end
