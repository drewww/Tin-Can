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

#define CORNER 0
#define SHARED_X 1
#define SHARED_Y 2

#define BORDER_WIDTH 15

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
            
            UIView *userView = [user getView];
            UIView *nextUserView = [nextUser getView];
            
            // We're going to have two paths here - if they're on the same edge, it's easy
            // and we just draw a rectange between them. If they're around a corner, we
            // need to be a bit more savvy. 
            int connectionType = [self hasSharedEdgeBetweenView:[user getView] andView:[nextUser getView]];
            
            CGRect edgeRect;
            CGContextSetFillColorWithColor(ctx, loc.color.CGColor);
            
            // Don't actually need this now. It's a vestige from a previous attempt to do all this nicely with rotations
            // that totally bombed because of rotation anchor issues that I didn't feel like fixing. Doing it manually
            // now. 
            CGContextSaveGState(ctx);
            float edge;
            switch (connectionType) {
                case CORNER:
                    NSLog(@"Handling the corner case.");

                    break;
                case SHARED_X:
                    
                    // There are a bunch of minor transpositions that have to happen for each side independently. Splitting them out
                    // into if blocks is a bit ugly, but it works and we don't realllly need a more general solution than this anyway.
                    // We're not going to have 8 sides all of a sudden. 
                    if(userView.frame.origin.x > 100) {
                        NSLog(@"on the top edge");
                        // Then we're on the top edge.
                        edge = 768-BORDER_WIDTH;
                        edgeRect = CGRectMake(edge, userView.center.y, BORDER_WIDTH, abs(userView.center.y - nextUserView.center.y));
                    } else {
                        NSLog(@"On the bottom edge");
                        // we're on the bottom edge
                        edge = BORDER_WIDTH;
                        edgeRect = CGRectMake(edge, nextUserView.center.y, BORDER_WIDTH, abs(userView.center.y - nextUserView.center.y));
                    }
                    
                    edgeRect = CGRectMake(edge, userView.center.y, BORDER_WIDTH, abs(userView.center.y - nextUserView.center.y));
                    CGContextFillRect(ctx, edgeRect);
                    break;
                case SHARED_Y:
                    
                    
                    if(userView.frame.origin.y > 100) {
                        NSLog(@"on the right edge");
                        // Then we're on the right edge.
                        edge = 1024-BORDER_WIDTH;
                        edgeRect = CGRectMake(nextUserView.center.x, edge, abs(userView.center.x - nextUserView.center.x), BORDER_WIDTH);
                    } else {
                        NSLog(@"on the left edge");
                        // we're on the left edge
                        edge = BORDER_WIDTH;
                        edgeRect = CGRectMake(userView.center.x, edge, abs(userView.center.x - nextUserView.center.x), BORDER_WIDTH);
                    }                    
                    CGContextFillRect(ctx, edgeRect);
                    break;                    
            }            
            
            CGContextRestoreGState(ctx);
        }
    }
    
}

- (int) hasSharedEdgeBetweenView:(UIView *)view1 andView:(UIView *)view2 {
    
    // (there are some cases here we're not testing that we shouldn't see
    //  for instance, two people on opposite sides at the same y position
    //  might show up as being SHARED_Y even when they're not. We shouldn't
    //  see this case, though, because we check views in order, and this
    //  situation can't happen with consecutive views.)
    if(view1.center.x == view2.center.x) {
        return SHARED_X;
    } else if(view1.center.y == view2.center.y) {
        return SHARED_Y;
    } else {
        return CORNER;
    }
}

- (void)dealloc {
    [super dealloc];
}


@end