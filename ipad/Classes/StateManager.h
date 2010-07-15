//
//  StateManager.h
//  TinCan
//
//  Created by Drew Harry on 7/14/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StateManager : NSObject {
    NSMutableDictionary *db;
    
}

- (void) putObj:(NSObject *)obj withUUID:(NSString *)uuid;
- (NSObject *) getObjWithUUID:(NSString *)uuid withType:(Class) aClass;


+ (StateManager*)sharedInstance;

@end
