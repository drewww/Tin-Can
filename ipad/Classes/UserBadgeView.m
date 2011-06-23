//
//  UserBadgeView.m
//  TinCan
//
//  Created by Drew Harry on 6/23/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "UserBadgeView.h"

#define BADGE_DIAMETER 30

@implementation UserBadgeView

- (id)init
{
    self = [super initWithFrame:CGRectMake(-BADGE_DIAMETER/2, -BADGE_DIAMETER, BADGE_DIAMETER, BADGE_DIAMETER)];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
        
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:191.0/255.0 green:101.0/255.0 blue:114.0/255.0 alpha:1.0].CGColor);
        
    CGContextFillEllipseInRect(ctx, CGRectMake(0,0, BADGE_DIAMETER, BADGE_DIAMETER));
    CGContextStrokeEllipseInRect(ctx, CGRectMake(0,0, BADGE_DIAMETER, BADGE_DIAMETER));
    
    // Now we're going to draw the icon (later)
}


- (void)dealloc
{
    [super dealloc];
}

@end
