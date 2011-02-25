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
#import "Topic.h"
#import "Task.h"
#import "UIColor+Util.h"

static StateManager *sharedInstance = nil;

@implementation StateManager

@synthesize meeting;
@synthesize location;
@synthesize user;

#pragma mark -
#pragma mark class instance methods
- (id) init {
    self = [super init];
    db = [[NSMutableDictionary dictionary] retain];

    NSLog(@"db: %@", db);
    return self;
}


- (void) putObj:(NSObject *)obj withUUID:(UUID *) uuid {
    NSLog(@"obj: %@ uuid: %@", obj, uuid);
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

    if(db!=nil) [db release];
    if(actors!=nil) [actors release];
    if(rooms !=nil) [rooms release];
    if(meetings!=nil) [meetings release];
    
    db = [[NSMutableDictionary dictionary] retain];
    actors = [[NSMutableSet set] retain];
    rooms = [[NSMutableSet set] retain];
    meetings = [[NSMutableSet set] retain];
    
    // Do this in two passes. Make the objects first, then
    // unswizzle them to convert UUIDs into actual objects.
    NSDate *date;
    for(NSDictionary *userDict in newUsers) {

        
        if([[userDict objectForKey:@"statusTime"] isKindOfClass:[NSNull class]]) {
            date = nil;
        } else {
            date = [NSDate dateWithTimeIntervalSince1970:[[userDict objectForKey:@"statusTime"] doubleValue]];
        }
        
        
        User *newUser = [[User alloc] initWithUUID:[userDict objectForKey:@"uuid"]
                                          withName:[userDict objectForKey:@"name"]
                                  withLocationUUID:[userDict objectForKey:@"location"]
                                        withStatus:[userDict objectForKey:@"status"]
                                            atDate:date];

        
        [actors addObject:newUser];
    }
    
    for(NSDictionary *l in newLocations) {
        Location *newLocation = [[Location alloc] initWithUUID:[l objectForKey:@"uuid"]
                                                      withName:[l objectForKey:@"name"]
                                                   withMeeting:[l objectForKey:@"meetingUUID"]
                                                     withUsers:[l objectForKey:@"users"]
                                                     withColor:[UIColor colorWithHexString:[l objectForKey:@"color"]]
                                                    ];
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
    
    for(NSDictionary *m in newMeetings) {
        
        Meeting *newMeeting = [[Meeting alloc] initWithUUID:[m objectForKey:@"uuid"]
                                                  withTitle:[m objectForKey:@"title"]
                                               withRoomUUID:[m objectForKey:@"room"]
                                                  startedAt:[NSDate dateWithTimeIntervalSince1970:[[m objectForKey:@"startedAt"] doubleValue]]];
        
        [meetings addObject:newMeeting];
        
        // Now unpack tasks and topics.
        // Since the meeting has been created, we can safely unswizzle each of these
        // as we make them. Their references only point to objects that will already
        // exist at this point.
        for(NSDictionary *results in [m objectForKey:@"tasks"]) {
            NSLog(@"unpacking task: %@", results);
            
            if([[results objectForKey:@"assignedAt"] isKindOfClass:[NSNull class]]) {
                date = nil;
            } else {
                date = [NSDate dateWithTimeIntervalSince1970:[[results objectForKey:@"assignedAt"] doubleValue]];
            }
            
            Task *task = [[Task alloc] initWithUUID:[results objectForKey:@"uuid"]
                              withCreatorUUID:[results objectForKey:@"createdBy"]
                                    createdAt:[NSDate dateWithTimeIntervalSince1970:[[results objectForKey:@"createdAt"] doubleValue]]
                              withMeetingUUID:[results objectForKey:@"meeting"]
                                     withText:[results objectForKey:@"text"]
                               assignedToUUID:[results objectForKey:@"assignedTo"]
                               assignedByUUID:[results objectForKey:@"assignedBy"]
                                   assignedAt:date
                                    withColor:[UIColor colorWithHexString:[results objectForKey:@"color"]]];
            [task unswizzle];
        }
        
        for(NSDictionary *results in [m objectForKey:@"topics"]) {
            NSLog(@"unpacking topics: %@", results);
         
            // This is the exact same code as in ConnectionManager.m's NEW_TOPIC handling code.
            // I'd like a way to abstract this out, but I don't really want to make the argument
            // for topic withStartTime a generic object. That's the only real solution I see,
            // and it feels weird to push this code in there. 
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
            
            
            Topic *topic = [[Topic alloc] initWithUUID:[results objectForKey:@"uuid"]
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

            
            [topic unswizzle];
        }
    }
    
    NSLog(@"Done with first pass of GET_STATE.");
    
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

- (NSSet *) getLocations {
    NSLog(@"in getLocations");
    NSMutableArray *allLocations = [NSMutableArray array];
    
    // Don't use actors directly, copy it and then iterate.
    for(Actor *actor in [[actors copy] autorelease]) {
        if([actor isKindOfClass:[Location class]]) {
            NSLog(@"found a location! %@", actor);
            [allLocations addObject:actor];
        }
    }
    
    return [NSSet setWithArray:allLocations];
}

- (NSSet *) getRooms {
    NSLog(@"in getRooms");
    NSMutableArray *allRooms = [NSMutableArray array];
    for(Room *room in [[rooms copy] autorelease]) {
			NSLog(@"found a Room! %@", room);
            [allRooms addObject:room];
        }

    return [NSSet setWithArray:allRooms];
}

- (NSSet *) getUsers {
    NSMutableArray *allUsers = [NSMutableArray array];
    
    // Don't use actors directly, copy it and then iterate.
    for(Actor *actor in [[actors copy] autorelease]) {
        if([actor isKindOfClass:[User class]]) {
            [allUsers addObject:actor];
        }
    }
    
    return [NSSet setWithArray:allUsers];
}


- (void) addActor:(Actor *)newActor {
    [actors addObject:newActor];
}

- (void) addMeeting:(Meeting *)newMeeting {
    [meetings addObject:newMeeting];
}

- (void) removeActor:(Actor *)actorToRemove {
    [actors removeObject:actorToRemove];
}

- (void) removeMeeting:(Meeting *)meetingToRemove {
    [actors removeObject:meetingToRemove];
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