//
//  StateManager.m
//  TinCan
//
//  Created by Drew Harry on 7/14/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//
//
// Singleton code structure taken from:
// http://stackoverflow.com/questions/145154/what-does-your-objective-c-singleton-look-like

#import "StateManager.h"
#import "User.h"
#import "tincan.h"

static StateManager *sharedInstance = nil;

@implementation StateManager

#pragma mark -
#pragma mark class instance methods
- (id) init {
    self = [super init];
    db = [NSMutableDictionary dictionary];
    
    return self;
}


- (void) putObj:(NSObject *)obj withUUID:(UUID *) uuid {
    [db setObject:obj forKey:uuid];
}

- (NSObject *) getObjWithUUID:(UUID *) uuid withType:(Class) aClass {
    
    NSObject *obj = [db objectForKey:uuid];
    
    if(obj==nil) {
        NSLog(@"No known object with UUID %@", uuid);
        return nil;
    }
    
    if([obj isKindOfClass:aClass]) {
        return obj;
    } else {
        NSLog(@"Object UUID %@ is type %@ not the specified type.", uuid, obj.class);
        return nil;
    }
}

- (void) initWithLocations:(NSArray *)newLocations withUsers:(NSArray *)newUsers
              withMeetings:(NSArray *)newMeetings withRooms:(NSArray *)newRooms {

    db = [NSMutableDictionary dictionary];
    actors = [NSMutableSet set];
    rooms = [NSMutableSet set];
    meetings = [NSMutableSet set];
    
    
    // Do this in two passes. Make the objects first, then
    // unswizzle them to convert UUIDs into actual objects.
    for(NSDictionary *user in newUsers) {
        User *newUser = [[User alloc] initWithUUID:[user objectForKey:@"uuid"]
                                          withName:[user objectForKey:@"name"]
                                  withLocationUUID:[user objectForKey:@"location"]];
        
        [actors addObject:newUser];
    }
    
    for(NSDictionary *location in newLocations) {
        
        Location *newLocation = [[Location alloc] initWithUUID:[location objectForKey:@"uuid"]
                                                      withName:[location objectForKey:@"name"]
                                                   withMeeting:[location objectForKey:@"meeting"]
                                                     withUsers:[location objectForKey:@"users"]];
        [actors addObject:newLocation];
    }
    
    
    for(NSDictionary *room in newRooms) {
        
        // We're not handling the with-meetings clause here. Might we need to? Not sure.
        // Hoping it happens during unswizzle instead. Not sure if that's the right strategy
        // for this.
        Room *newRoom = [[Room alloc] initWithUUID:[room objectForKey:@"uuid"]
                                          withName:[room objectForKey:@"name"]];
        
        [rooms addObject:newRoom];
    }
    
    for(NSDictionary *meeting in newMeetings) {
     
        Meeting *newMeeting = [[Meeting alloc] initWithUUID:[meeting objectForKey:@"uuid"]
                                                  withTitle:[meeting objectForKey:@"title"]
                                               withRoomUUID:[meeting objectForKey:@"room"]];
        
        [meetings addObject:newMeeting];
    }
    
    
    // Unswizzle in the proper order.
    [self unswizzleGroup:actors];
    [self unswizzleGroup:rooms];
    [self unswizzleGroup:meetings];
    
    NSLog(@"actors: %@", actors);
    NSLog(@"rooms: %@", rooms);
    NSLog(@"meetings: %@", meetings);    
}

- (void) unswizzleGroup:(NSSet *)groupToUnswizzle {
    for(SynchronizedObject *object in groupToUnswizzle) {
            [object unswizzle];   
        }
}


#pragma mark -
#pragma mark Singleton methods

+ (StateManager*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
            sharedInstance = [[StateManager alloc] init];
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