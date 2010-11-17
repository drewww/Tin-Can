//
//  UserRenderView.m
//  TinCan
//
//  Created by Drew Harry on 8/5/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "UserRenderView.h"
#import "UIColor+Util.h"

// For constants.
#import "UserView.h"

@implementation UserRenderView

@synthesize user;
@synthesize hover;

- (id) initWithUser:(User *)theUser {
    
    NSLog(@"In initWithUser for userRENDERview");
    self = [super initWithFrame:CGRectMake(0, 0, BASE_WIDTH, BASE_HEIGHT + TAB_HEIGHT)];
    
    self.user = theUser;
    hover = FALSE;
    
    self.bounds = CGRectMake(-BASE_WIDTH/2, -(BASE_HEIGHT + TAB_HEIGHT)/2, BASE_WIDTH, BASE_HEIGHT + TAB_HEIGHT);
    self.center = CGPointMake(0, 0);
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    showStatus = FALSE;
    
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
    
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    CGContextAddEllipseInRect(ctx, CGRectMake(-10, -10, 20, 20));
    CGContextFillPath(ctx);
    
	if(hover)
        CGContextSetFillColorWithColor(ctx, [user.location.color colorDarkenedByPercent:0.3].CGColor);
	else
		CGContextSetFillColorWithColor(ctx, user.location.color.CGColor);
    
    
    CGFloat topEdge;
    
    topEdge = -BASE_HEIGHT/2 +10;
    
    [self fillRoundedRect:CGRectMake(-BASE_WIDTH/2, topEdge, BASE_WIDTH, BASE_HEIGHT) withRadius:10 withRoundedBottom:true];        
    
    
    CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
    CGContextSetRGBStrokeColor(ctx, 1.0, 0.0, 0.0, 1.0);
    
    UIFont *f = [UIFont boldSystemFontOfSize:16];
    CGSize nameSize = [[self.user.name uppercaseString] sizeWithFont:f];
    
    [[self.user.name uppercaseString] drawAtPoint:CGPointMake(-nameSize.width/2, -nameSize.height-NAME_BOTTOM_MARGIN) withFont:f];
    
    // Draw the status block..
    f = [UIFont boldSystemFontOfSize:16];

    NSString *statusString = user.status;
    
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
    [statusString drawAtPoint:CGPointMake(-statusSize.width/2, 2) withFont:f];
    

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
    CGFloat xPos = 15;
    NSLog(@"about to render a user, with %d tasks", [user.tasks count]);
    
    for (int i=0; i<[user.tasks count]; i++) {
        CGContextFillRect(ctx, CGRectMake(xPos-BASE_WIDTH/2, topEdge-TAB_HEIGHT+8, TAB_WIDTH, TAB_HEIGHT-8));
        
        xPos += TAB_MARGIN + TAB_WIDTH;
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


- (void) fillRoundedRect:(CGRect)boundingRect withRadius:(CGFloat)radius withRoundedBottom:(bool)roundedBottom{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // This code lifted from Apple's quartz example code:
    // http://developer.apple.com/iphone/library/samplecode/QuartzDemo/Listings/Quartz_QuartzCurves_m.html
    
    // If you were making this as a routine, you would probably accept a rectangle
    // that defines its bounds, and a radius reflecting the "rounded-ness" of the rectangle.
    CGRect rrect = boundingRect;
    
    // NOTE: At this point you may want to verify that your radius is no more than half
    // the width and height of your rectangle, as this technique degenerates for those cases.
    
    // In order to draw a rounded rectangle, we will take advantage of the fact that
    // CGContextAddArcToPoint will draw straight lines past the start and end of the arc
    // in order to create the path from the current position and the destination position.
    
    // In order to create the 4 arcs correctly, we need to know the min, mid and max positions
    // on the x and y lengths of the given rectangle.
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    
    // Next, we will go around the rectangle in the order given by the figure below.
    //       minx    midx    maxx
    // miny    2       3       4
    // midy   1 9              5
    // maxy    8       7       6
    // Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
    // form a closed path, so we still need to close the path to connect the ends correctly.
    // Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
    // You could use a similar technique to create any shape with rounded corners.
    
    // Start at 1
    CGContextMoveToPoint(ctx, minx, midy);
    // Add an arc through 2 to 3
    CGContextAddArcToPoint(ctx, minx, miny, midx, miny, radius);
    // Add an arc through 4 to 5
    CGContextAddArcToPoint(ctx, maxx, miny, maxx, midy, radius);
    
    if(roundedBottom) {
        // Add an arc through 6 to 7
        CGContextAddArcToPoint(ctx, maxx, maxy, midx, maxy, radius);
        // Add an arc through 8 to 9
        CGContextAddArcToPoint(ctx, minx, maxy, minx, midy, radius);
    } else {
        // Just go directly to the next two corners, with no arc.
        CGContextAddLineToPoint(ctx, maxx, maxy);
        CGContextAddLineToPoint(ctx, minx, maxy);
        CGContextAddLineToPoint(ctx, minx, midy);
    }
    
    // Close the path
    CGContextClosePath(ctx);
    // Fill & stroke the path
    CGContextDrawPath(ctx, kCGPathFillStroke);   
    
}

- (void)dealloc {
    [super dealloc];
}


@end
