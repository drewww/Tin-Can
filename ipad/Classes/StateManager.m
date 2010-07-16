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