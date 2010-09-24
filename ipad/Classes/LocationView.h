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
	UIColor *color;
    Location *location;
}

@property (nonatomic, retain) Location *location;

- (id) initWithLocation:(Location *)theLocation;
- (id) initWithFrame:(CGRect)frame withLocation:(Location *)theLocation;

@end
