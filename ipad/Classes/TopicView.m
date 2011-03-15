//
//  TopicView.m
//  TinCan
//
//  Created by Paula Jacobs on 8/11/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "TopicView.h"
#import "Topic.h"
#import "ConnectionManager.h"
#import "UIColor+Util.h"


@implementation TopicView

@synthesize topic;

#define NO_BUTTON_SELECTED 0
#define CANCEL_BUTTON_SELECTED 1
#define START_BUTTON_SELECTED 2

#define DRAG_CIRCLE_RADIUS 8

#define HEIGHT 60

- (id)initWithFrame:(CGRect)frame withTopic:(Topic *)theTopic{
    if ((self = [super initWithFrame:frame])) {
		self.frame=frame;
        topic=theTopic;
        
        optionSliderX = -1;
        
		self.userInteractionEnabled = YES; 
		isTouched= FALSE;
        
        [self setBackgroundColor:[UIColor blackColor]];
		
        
		self.alpha = 0;
		[UIView beginAnimations:@"fade_in" context:self];
		
		[UIView setAnimationDuration:.3f];
		
		self.alpha = 1.0;
		
		
		[UIView commitAnimations];
    }
    return self;
}

- (id) initWithTopic:(Topic*)theTopic {
    
    // This is just a weak passthrough. Eventually, we'll knock out the initWithFrame
    // version and initWithTopic will be the only option. Leaving the old one for compatibility
    // reasons, because making tasks by hand on the client is a bit tedious for testing.
    
    return [self initWithFrame:CGRectMake(0, 0, 230, HEIGHT) withTopic:theTopic];
}


-(void)setFrameWidthWithContainerWidth:(CGFloat )width{
	self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, (width)-20, self.frame.size.height);
}

- (void)drawRect:(CGRect)rect {
    
    // Drawing code
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
//    CGContextSetRGBFillColor(ctx, 0, 0, 0, 1.0);
//    CGContextFillRect(ctx, self.frame);

    
    
    // We're going to draw a little arc that represents the time this topic was talked about, if 
    // the topic has started or finished. If it hasn't started yet, we'll put a start button
    // there instead.
    
    if(topic.status == kPAST || topic.status == kCURRENT) {        
        
        UIColor *background;
        if(topic.status == kCURRENT) {            
            background = [topic.color colorByChangingAlphaTo:0.3];
        } else {
            background = [UIColor blackColor];
        }
        
        self.backgroundColor = background;
        
        // In this mode, we're basically going to steal the rendering code from the clock. We want to
        // make a little arc.  
        
        // First, figure out the rotation we need. That's based on the start time.
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:topic.startTime];
        NSInteger minute = [dateComponents minute];
        NSInteger second = [dateComponents second];
        [gregorian release];
        float rotation = ((minute*60 + second)/3600.0f) * (2*M_PI);
        
        CGContextMoveToPoint(ctx, 0, 0);
        
//        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.7 alpha:1.0].CGColor);

        
        //lets draw our TIME ARC!
        NSDate *endTime;
        
        if(topic.stopTime != nil) {
            endTime = topic.stopTime;
        } else {
            endTime = [NSDate date];
        }
        
        float elapsedTime = abs([topic.startTime  timeIntervalSinceDate:endTime ]);

        
        // First, clear the circle so the background color doesn't show through.
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextStrokeEllipseInRect(ctx, CGRectMake(4, 4, 42, 42));
                
        CGContextSetFillColorWithColor(ctx, topic.color.CGColor);
        CGFloat arcLength = elapsedTime/3600.0f * (2*M_PI);
        CGContextMoveToPoint(ctx, 25, 25);
                
        //CGContextAddArc(ctx, 25, 25, 50, -M_PI/2 - arcLength, -M_PI/2 , 0); 
        CGContextMoveToPoint(ctx, 25, 25);
        CGContextAddArc(ctx, 25, 25, 21, rotation- M_PI/2, rotation + arcLength - M_PI/2, 0);
        CGContextFillPath(ctx);
                
        // Now draw the clock outline. A pair of 1px circles at the right radii should do it.
        CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.6 alpha:1.0].CGColor);
        CGContextStrokeEllipseInRect(ctx, CGRectMake(4, 4, 42, 42));
    } else {
        
        CGContextSaveGState(ctx);
        CGContextTranslateCTM(ctx, 25, self.frame.size.height/2);
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:1.0 alpha:0.7].CGColor);
        CGContextFillEllipseInRect(ctx, CGRectMake(-DRAG_CIRCLE_RADIUS, -DRAG_CIRCLE_RADIUS, DRAG_CIRCLE_RADIUS*2, DRAG_CIRCLE_RADIUS*2));
        CGContextRestoreGState(ctx);
                
    }

    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:1 green:1 blue:1 alpha:1.0].CGColor);
    
	[topic.text drawInRect:CGRectMake(54, 2, self.frame.size.width-54, self.frame.size.height-10) 
			withFont:[UIFont systemFontOfSize:16] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
	
    
    if(optionSliderX!=-1) {
        // First, draw a black rectangle over everything to dim out the background a bit.
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.0 alpha:0.6].CGColor);
        CGContextFillRect(ctx, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
        
        
        // decide which button is selected, so we can draw it differently.
        int buttonSelected = [self getSelectedButton];
        // Draw the droppable options.
        // They are:
        //  - cancel
        //  - reorder
        //  - start
        //  - restart
        //  - delete?
        CGContextSaveGState(ctx);
        
        CGContextTranslateCTM(ctx, 25, self.frame.size.height/2);
        
        // Trying it without the cancel button, since it's a bit ambiguous.
//        CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
//        
//        if(buttonSelected == CANCEL_BUTTON_SELECTED) {
//            CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.5 alpha:0.6].CGColor);
//        } else {
//            CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.2 alpha:0.6].CGColor);   
//        }
//
//        
//        CGContextStrokeEllipseInRect(ctx, CGRectMake(-24, -24, 48, 48));
//        CGContextFillEllipseInRect(ctx, CGRectMake(-24, -24, 48, 48));
//        
//        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.8 alpha:1.0].CGColor);
//        [@"CANCEL" drawInRect:CGRectMake(-23, -6, 50, 12) withFont:[UIFont boldSystemFontOfSize:11]];
 
        CGContextTranslateCTM(ctx, 185, 0);

        CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
        if(buttonSelected == START_BUTTON_SELECTED) {
            CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.5 alpha:0.6].CGColor);
        } else {
            CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.2 alpha:0.6].CGColor);   
        }
        
        CGContextStrokeEllipseInRect(ctx, CGRectMake(-24, -24, 48, 48));
        CGContextFillEllipseInRect(ctx, CGRectMake(-24, -24, 48, 48));
        
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.8 alpha:1.0].CGColor);
        if(topic.status == kFUTURE) {
            [@"START" drawInRect:CGRectMake(-18, -6, 50, 12) withFont:[UIFont boldSystemFontOfSize:10]];
        } else if(topic.status == kCURRENT) {
            [@"STOP" drawInRect:CGRectMake(-15, -6, 50, 12) withFont:[UIFont boldSystemFontOfSize:10]];            
        } else if(topic.status == kPAST) {
            [@"RESTART" drawInRect:CGRectMake(-22, -6, 50, 12) withFont:[UIFont boldSystemFontOfSize:10]];                        
        }
        
        
        CGContextRestoreGState(ctx);
        
        // Now draw the selector; a circle that'll move with your touch.
        CGContextSaveGState(ctx);
        
        CGContextTranslateCTM(ctx, optionSliderX, self.frame.size.height/2);
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:1.0 alpha:0.7].CGColor);
        CGContextFillEllipseInRect(ctx, CGRectMake(-DRAG_CIRCLE_RADIUS, -DRAG_CIRCLE_RADIUS, DRAG_CIRCLE_RADIUS*2, DRAG_CIRCLE_RADIUS*2));
    }
    
    
    
	[self setNeedsDisplay];
	
}

- (int) getSelectedButton {
    
    int buttonSelected = NO_BUTTON_SELECTED;
    
    if(optionSliderX < 50) {
        buttonSelected = CANCEL_BUTTON_SELECTED;
    } else if(optionSliderX < 230 && optionSliderX > 176) {
        buttonSelected = START_BUTTON_SELECTED;
    }
    
    return buttonSelected;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // In this new system, when we get a touch (in the right area) we want to pull
    // up the option selection UI.
    
    // Accept any touch on the left side of the topic item.
    UITouch *touch = [touches anyObject];
    
    CGPoint touchLoc = [touch locationInView:self];
    
    if(touchLoc.x < 40) {
        NSLog(@"Got a touch in the right place.");
        optionSliderX = touchLoc.x;
        
        [self setNeedsDisplay];
    }    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(optionSliderX != -1) {
        // If we've already started moving from a valid position,
        // update the location for the selector.
        CGPoint touchLoc = [[touches anyObject] locationInView:self];
        
        optionSliderX = touchLoc.x;
        [self setNeedsDisplay];
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {


    int buttonSelected = [self getSelectedButton];
    
    if(buttonSelected == START_BUTTON_SELECTED) {
        if (topic.status == kFUTURE){
            NSLog(@"Future item touched - end the current item and make this one current.");
            [[ConnectionManager sharedInstance] updateTopic:topic withStatus:kCURRENT];
        }
        else if(topic.status == kCURRENT){
            NSLog(@"Current item touched - end it.");
            [[ConnectionManager sharedInstance] updateTopic:topic withStatus:kPAST];
        } else if (topic.status == kPAST) {
            NSLog(@"Restarting item.");
            [[ConnectionManager sharedInstance] restartTopic:topic];
        }
    }
    
    optionSliderX = -1;
    [self setNeedsDisplay];
}

- (NSComparisonResult) compareByState:(TopicView *)view {
    
    // Tries to comare by strings, but if they end up being exactly the same string,
    // it will resolve the ties by comparing pointers. This is a deterministic comparison
    // and an arbitrary (but stable) way to tell between tasks with identical text.
    // This is a rare case in real use, but happens a lot in testing, so this gives us some
    // protection from bad issues during demoing.
	
    NSComparisonResult retVal;
    if(topic.status < view.topic.status) {
        retVal = NSOrderedAscending;
    } else if (topic.status > view.topic.status) {
        retVal = NSOrderedDescending;
    }
    
	if(topic.status == view.topic.status) {
		if(topic.status == kPAST){
			retVal=[topic.startTime compare:view.topic.startTime];
		}
        // For future items, ordering doesn't matter (although we might order by creation time - or will there be some pre-meeting fixed ordering?)
        // For current items, there can be only one. Perhaps throw an error if we hit more than one in this process?
	}
	
    return retVal;
}
- (void)dealloc {
    [super dealloc];
}


@end
