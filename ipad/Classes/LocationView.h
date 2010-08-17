//
//  LocationView.h
//  TinCan
//
//  Created by Paula Jacobs on 8/13/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"

@interface LocationView : UIView {
	NSString *name;
	int numUsers;
}

- (id) initWithLocation:(Location *)theLocation;
- (id) initWithFrame:(CGRect)frame withName:(NSString *)theName withUsers:(int)users;

@property (nonatomic, retain) NSString *name;

@end
