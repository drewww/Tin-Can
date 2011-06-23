//
//  UserRenderView.m
//  TinCan
//
//  Created by Drew Harry on 8/5/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "UserRenderView.h"
#import "UIColor+Util.h"
#import "UIView+Rounded.h"
#import "StateManager.h"

// For constants.
#import "UserView.h"

#define LOCAL_USER_GLOW 5

@implementation UserRenderView

@synthesize user;
@synthesize hover;

- (id) initWithUser:(User *)theUser {
    
    NSLog(@"In initWithUser for userRENDERview");
    self = [super initWithFrame:CGRectMake(0, 0, BASE_WIDTH, BASE_HEIGHT + TAB_HEIGHT)];
    
    self.user = theUser;
    hover = FALSE;
    
    self.bounds = CGRectMake(-BASE_WIDTH/2-LOCAL_USER_GLOW*2, -(BASE_HEIGHT + TAB_HEIGHT)/2, BASE_WIDTH+LOCAL_USER_GLOW*4, BASE_HEIGHT + TAB_HEIGHT);
    self.center = CGPointMake(0, 0);
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    showStatus = FALSE;
    animating = false;
    
    badgeView = [[UserBadgeView alloc] initWithUser:self.user];
    badgeView.center = CGPointMake(BASE_WIDTH/2-10, -BASE_HEIGHT/2+20);
    badgeView.hidden = true;
    [self addSubview:badgeView];
    
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    NSLog(@"In drawRect for userRENDERview");
    NSLog(@"color is now: %@", user.location.color);

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    if(ctx==nil) {
        NSLog(@"Failed to get graphics context.");
        return;
    }
    

    CGFloat topEdge;
    
    topEdge = -BASE_HEIGHT/2 +10;    
    
    bool isLocalUser = [StateManager sharedInstance].user == self.user;

    // Do a bit of a dance here to make a glow effect. We're cheating by doing three
    // separate shadows, each offset in a different direction. This is because we 
    // can't just have the shadow grow outwards, so it takes a bit more effort.
    if(isLocalUser) {
        NSLog(@"DRAWING LOCAL USER");
        CGContextSaveGState(ctx);
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, -LOCAL_USER_GLOW), LOCAL_USER_GLOW, user.location.color.CGColor);
        
        CGContextSetFillColorWithColor(ctx, user.location.color.CGColor);
        [self fillRoundedRect:CGRectMake(-BASE_WIDTH/2, topEdge, BASE_WIDTH, BASE_HEIGHT) withRadius:10 withRoundedBottom:true];        

        
        CGContextSetShadowWithColor(ctx, CGSizeMake(LOCAL_USER_GLOW, 0), LOCAL_USER_GLOW, user.location.color.CGColor);        
        [self fillRoundedRect:CGRectMake(-BASE_WIDTH/2, topEdge, BASE_WIDTH, BASE_HEIGHT) withRadius:10 withRoundedBottom:true];        

        CGContextSetShadowWithColor(ctx, CGSizeMake(-LOCAL_USER_GLOW, 0), LOCAL_USER_GLOW, user.location.color.CGColor);        
        [self fillRoundedRect:CGRectMake(-BASE_WIDTH/2, topEdge, BASE_WIDTH, BASE_HEIGHT) withRadius:10 withRoundedBottom:true];        
        
        
        CGContextRestoreGState(ctx);
    }
    
	if(hover)
        CGContextSetFillColorWithColor(ctx, [user.location.color colorDarkenedByPercent:0.3].CGColor);
	else
		CGContextSetFillColorWithColor(ctx, user.location.color.CGColor);
    
    [self fillRoundedRect:CGRectMake(-BASE_WIDTH/2, topEdge, BASE_WIDTH, BASE_HEIGHT) withRadius:10 withRoundedBottom:true];        
        
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(ctx, 1.0, 0.0, 0.0, 1.0);
    
    UIFont *f = [UIFont boldSystemFontOfSize:16];
    CGSize nameSize = [[self.user.name uppercaseString] sizeWithFont:f];
    
    CGContextSaveGState(ctx);
    if([((UserView *)self.superview).side isEqualToNumber:[NSNumber numberWithInt:0]]) {
        CGContextRotateCTM(ctx, M_PI);
        [[self.user.name uppercaseString] drawAtPoint:CGPointMake(-nameSize.width/2, NAME_BOTTOM_MARGIN) withFont:f];
    } else {
        [[self.user.name uppercaseString] drawAtPoint:CGPointMake(-nameSize.width/2, -nameSize.height-NAME_BOTTOM_MARGIN) withFont:f];
    }
    
    
    CGContextRestoreGState(ctx);

    
    // Draw the status block..
    f = [UIFont boldSystemFontOfSize:16];

    NSString *statusString = user.statusMessage;
    
    if(statusString != nil) {
        // We're also going to look at when it happened. If it was too long ago, don't show it
        // at all. If it's within a certain range, just dim the color of the text proportionally.
        
        // The -1 is to make these values positive, just for convenience. Otherwise, "timeIntervalSinceNow" 
        // is always negative for past times.
        NSTimeInterval timeSinceStatus = [user.statusDate timeIntervalSinceNow]*-1;
        NSLog(@"timeSinceStatus: %f", timeSinceStatus);
        // if it's more than 10 minutes old, don't show it at all
        if(timeSinceStatus < 10*60) {
            
            // Now, if it's in the last 2 minutes, do full color. Otherwise, fade it.
            float colorFraction = 1.0;
            if(timeSinceStatus > 2 * 60) {
                colorFraction = ((timeSinceStatus-(2*60))/(8*60))*0.8 + 0.2;
            }
            
            // Now set the color to be white, plus the colorFraction's alpha.
            CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:1.0 alpha:colorFraction].CGColor);            
        }  else {
            CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:1.0 alpha:0.5].CGColor);
            
            statusString = @"no recent activity";        
        }
    } else {
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:1.0 alpha:0.5].CGColor);
        
        statusString = @"no recent activity";        
    }
    
    CGSize statusSize = [statusString sizeWithFont:f];  
    CGContextSaveGState(ctx);
    if([((UserView *)self.superview).side isEqualToNumber:[NSNumber numberWithInt:0]]) {
        CGContextRotateCTM(ctx, M_PI);
        [statusString drawAtPoint:CGPointMake(-statusSize.width/2, -statusSize.height) withFont:f];
    } else {
        [statusString drawAtPoint:CGPointMake(-statusSize.width/2, 2) withFont:f];
    }
    CGContextRestoreGState(ctx);
    

    

    // Now draw the location name. It'll only show when extended, but we just draw it
    // all the time.
    f = [UIFont boldSystemFontOfSize:12];
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:1.0 alpha:1.0].CGColor);
    CGSize locationNameSize = [self.user.location.name sizeWithFont:f];
    
    
    [self.user.location.name drawAtPoint:CGPointMake(-locationNameSize.width/2, 5+22) withFont:f];
    
    // Now draw a thin, lighter line to separate it from the name and line it up with the location border
    // thickness.
    CGContextSetLineWidth(ctx, 0.5);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextMoveToPoint(ctx, -BASE_WIDTH/2, +5 + 22);
    CGContextAddLineToPoint(ctx, BASE_WIDTH/2, +5 + 22);
    CGContextStrokePath(ctx);
    
    
    // Draw the tabs to show that this person has tasks assigned.
    // Hardcoding the number of tasks for now.
    CGContextSetFillColorWithColor(ctx, [user.location.color colorByChangingAlphaTo:0.9].CGColor);
    NSLog(@"about to render a user, with %d tasks", [user.tasks count]);
    
    
    // 16 is our max, then we need to start chunking them. Lets make chunks of 5? 
    
    int sizeOfClump = 5;
    int numClumps = (int)([user.tasks count]/sizeOfClump);
    int remainder = [user.tasks count] % sizeOfClump;
    CGFloat xPos = 15;

    
    // draw the clumps
    for (int i=0; i<numClumps; i++) {
        CGContextFillRect(ctx, CGRectMake(xPos-BASE_WIDTH/2, topEdge-TAB_HEIGHT+8, TAB_WIDTH*3, TAB_HEIGHT-8));
        xPos += TAB_MARGIN + TAB_WIDTH*3;
    }
    
    // draw the singles
    for (int i=0; i<remainder; i++) {
        CGContextFillRect(ctx, CGRectMake(xPos-BASE_WIDTH/2, topEdge-TAB_HEIGHT+8, TAB_WIDTH, TAB_HEIGHT-8));
        xPos += TAB_MARGIN + TAB_WIDTH;
    }

//     
//    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
//    CGContextStrokeRect(ctx, CGRectMake(-2, -2, 4, 4));

    // This is the right way to do it if we don't want any clumping. 
//    for (int i=0; i<[user.tasks count]; i++) {
//        CGContextFillRect(ctx, CGRectMake(xPos-BASE_WIDTH/2, topEdge-TAB_HEIGHT+8, TAB_WIDTH, TAB_HEIGHT-8));
//        
//        xPos += TAB_MARGIN + TAB_WIDTH;
//    }
    

}

- (void) setBadgeVisibile:(bool)visible {
    
    if(animating) {
        return;
    }
    
    if(badgeView.hidden && visible) {
        badgeView.hidden = false;
        [badgeView setNeedsDisplay];
        [UIView animateWithDuration:0.5
                         animations:^{ 
                             animating = true;
                             badgeView.alpha = 1.0;
                         } 
                         completion:^(BOOL finished){
                             animating = false;
                         }];
        
    } else if (!badgeView.hidden && !visible) {
        // transition to invisibility
        [UIView animateWithDuration:0.5
                         animations:^{ 
                             animating = true;
                             badgeView.alpha = 0.0;
                         } 
                         completion:^(BOOL finished){
                             animating = false;
                             badgeView.hidden = true;
                         }];
    }
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //    
    //    showStatus = !showStatus;
    //    [self setNeedsDisplay];
    //   
    NSLog(@"touches ended on the user part of the userview");
    
    // animate the task drawer into position
    [(UserView *)self.superview userTouched];
    
}

- (void)dealloc {
    [super dealloc];
}


@end
