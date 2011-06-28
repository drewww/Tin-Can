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

- (id)initWithUser:(User *)theUser
{
    self = [super initWithFrame:CGRectMake(-BADGE_DIAMETER/2, -BADGE_DIAMETER, BADGE_DIAMETER, BADGE_DIAMETER)];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        user = [theUser retain];
        
//        icon = [[UIImage imageNamed:@"note_add.png"] retain];
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Queue off the setHidden so whenever this is shown
    // we've updated the image to be proper.
        // Now we're going to draw the icon (later)
//    UIImage *image;
        if(user.statusType == kTHUMBS_UP_STATUS) {
            icon = [UIImage imageNamed:@"thumb_up.png"];
            NSLog(@"setting image to THUMBS UP!");
        } else if (user.statusType == kEMPTY_STATUS) {
            icon = nil;
        }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
//        
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:191.0/255.0 green:101.0/255.0 blue:114.0/255.0 alpha:1.0].CGColor);
        
    CGContextFillEllipseInRect(ctx, CGRectMake(0,0, BADGE_DIAMETER, BADGE_DIAMETER));
    CGContextStrokeEllipseInRect(ctx, CGRectMake(0,0, BADGE_DIAMETER, BADGE_DIAMETER));

//    [icon drawInRect:self.bounds blendMode:<#(CGBlendMode)#> alpha:<#(CGFloat)#>];    
    
    if(icon!=nil) {
    [icon drawInRect:CGRectInset(self.bounds, 5, 5)];
//    [icon drawAtPoint:CGPointMake(-BADGE_DIAMETER/2+3, -BADGE_DIAMETER/2+3)];
//    [icon drawAtPoint:CGPointMake(-BADGE_DIAMETER/2, -BADGE_DIAMETER/2)];
    NSLog(@"DRAWING BADGE");
    }
    
    
}


- (void)dealloc
{
    [user retain];
    [super dealloc];
}

@end
