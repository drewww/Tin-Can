//
//  ManageUsersRenderView.m
//  TinCan
//
//  Created by Drew Harry on 6/8/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "ManageUsersRenderView.h"
#import "UIView+Rounded.h"

// This is a bit of a convenience class. It renders the bit of the manage users interface
// that has the title and accepts clicks. Nothing fancy. Doing it this way to mirror
// the user render view, which makes inheriting from ExtendableDrawerView somewhat
// easier.


#define BASE_HEIGHT 90
#define BASE_WIDTH 180

#define COLOR [UIColor colorWithWhite:0.3 alpha:1.0]

@implementation ManageUsersRenderView

- (id)init
{
    
    // Would be nice to plug this in somehow with the user inheritance pattern, but
    // I'm not sure how that's going to work, sooooo hardcoding.
    self = [super initWithFrame:CGRectMake(0, 0, BASE_WIDTH, BASE_HEIGHT)];
    
    if (self) {
        self.bounds = CGRectMake(-BASE_WIDTH/2, -(BASE_HEIGHT)/2, BASE_WIDTH, BASE_HEIGHT);
        self.center = CGPointMake(0, 0);
                
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(ctx, COLOR.CGColor);
    
    CGFloat topEdge;
    
    topEdge = -BASE_HEIGHT/2 +10;
    
    [self fillRoundedRect:CGRectMake(-BASE_WIDTH/2, topEdge, BASE_WIDTH, BASE_HEIGHT) withRadius:10 withRoundedBottom:true];        
    
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(ctx, 1.0, 0.0, 0.0, 1.0);
    
    UIFont *f = [UIFont boldSystemFontOfSize:16];
    
    NSString *name = @"MANAGE USERS";
    CGSize nameSize = [name sizeWithFont:f];
    
    [name drawAtPoint:CGPointMake(-nameSize.width/2, -nameSize.height-2) withFont:f];
}


- (void)dealloc
{
    [super dealloc];
}

@end
