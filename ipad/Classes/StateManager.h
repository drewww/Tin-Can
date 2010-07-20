//
//  StateManager.h
//  TinCan
//
//  Created by Drew Harry on 7/14/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tincan.h"

@interface StateManager : NSObject {
    NSMutableDictionary *db;
    
}

- (void) putObj:(NSObject *)obj withUUID:(UUID *)uuid;
- (NSObject *) getObjWithUUID:(UUID *)uuid withType:(Class) aClass;


+ (StateManager*)sharedInstance;

@end