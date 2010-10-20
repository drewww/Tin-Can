//
//  LocationBorderView.m
//  TinCan
//
//  Created by Drew Harry on 10/20/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "LocationBorderView.h"
#import "StateManager.h"
#import "User.h"
#import "Location.h"

@implementation LocationBorderView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    // Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();

    
    // Okay, on each draw cycle we'll look at the list of user views
    // and draw lines between users that are in the same location.
    
    NSArray *locations = [[StateManager sharedInstance].meeting.locations allObjects];
    
    for (Location *loc in locations) {
        CGContextSetStrokeColorWithColor(ctx, loc.color.CGColor);
        CGContextSetLineWidth(ctx, 4.0f);
        
        NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending: YES];
        NSArray *users = [[loc.users allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByName]];;
        
        for(int i=0; i<[users count]-1; i++) {
            User *user = [users objectAtIndex:i];
            User *nextUser = [users objectAtIndex:i+1];
            
            CGContextMoveToPoint(ctx, [user getView].center.x, [user getView].center.y);
            CGContextAddLineToPoint(ctx, [nextUser getView].center.x, [nextUser getView].center.y);
            CGContextStrokePath(ctx);
        }
    }
    
}

- (void)dealloc {
    [super dealloc];
}


@end
