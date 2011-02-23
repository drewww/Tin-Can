//
//  TopicContainerView.m
//  TinCan
//
//  Created by Paula Jacobs on 8/11/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "TopicContainerView.h"
#import "TopicView.h"
#import "AddItemController.h"
#import "TopicContainerContentView.h"
#import "ConnectionManager.h"

@implementation TopicContainerView

#define COLOR [UIColor colorWithWhite:0.3 alpha:1]
#define BUTTON_COLOR [UIColor colorWithWhite:0.6 alpha:1]
#define BUTTON_PRESSED_COLOR [UIColor colorWithWhite:0.45 alpha:1]


#define HEADER_HEIGHT 26

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.frame=frame;
		
        rot = M_PI/2;
        
        addButtonPressed = FALSE;
        
		[self setTransform:CGAffineTransformMakeRotation(rot)];	
        
        topicScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, self.bounds.size.width, self.bounds.size.height-HEADER_HEIGHT-2)];
        
        // The height on this one is just a placeholder - when it's layed out, it will calculate its own size.
        contentView = [[TopicContainerContentView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 50)];
        [contentView setNeedsLayout];
        
        [topicScrollView setCanCancelContentTouches:NO];
        topicScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;

        [topicScrollView addSubview:contentView];
        [self addSubview:topicScrollView];        
        
        
		[self setNeedsLayout];
        
        
        // Now setup the add topic popover.
        AddItemController *addTopicController = [[AddItemController alloc] initWithPlaceholder:@"new topic" withButtonText:@"Add Topic"];
        addTopicController.delegate = self;
        
        popoverController = [[UIPopoverController alloc] initWithContentViewController:addTopicController];

        [popoverController setPopoverContentSize:CGSizeMake(300, 100)];
    }
    
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(ctx, COLOR.CGColor);
	CGContextFillRect(ctx, CGRectMake(0, 0, self.bounds.size.width, HEADER_HEIGHT));
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	[@"TOPICS" drawInRect:CGRectMake(0, 1, self.bounds.size.width, HEADER_HEIGHT - 2) 
                withFont:[UIFont boldSystemFontOfSize:22] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	
	CGContextSetLineWidth(ctx,2);
	CGContextSetStrokeColorWithColor(ctx,  COLOR.CGColor);
	CGContextStrokeRect(ctx, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
	
    
    // Draw a + button in the header for adding tasks.
    if(addButtonPressed) {
        CGContextSetFillColorWithColor(ctx, BUTTON_PRESSED_COLOR.CGColor);
    } else {
        CGContextSetFillColorWithColor(ctx, BUTTON_COLOR.CGColor);
    }
    
//    buttonRect = CGRectMake(self.bounds.size.width-23, 3, 20, 20);
//    
//    CGContextFillRect(ctx, buttonRect);
//    
//    // Now put a plus in the middle of it. 
//    CGContextSetFillColorWithColor(ctx, COLOR.CGColor);
//    CGContextFillRect(ctx, CGRectInset(buttonRect, 9, 2));
//    CGContextFillRect(ctx, CGRectInset(buttonRect, 2, 9));    
}


- (void) itemSubmittedWithText:(NSString *)text fromController:(UIViewController *)controller {
    
    // dismiss the popover
    [popoverController dismissPopoverAnimated:true];
    
    // Send it to the server.
    [[ConnectionManager sharedInstance] addTopicWithText:text];
}

//- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    UITouch *touch = [touches anyObject];
//    
//    CGPoint touchLoc = [touch locationInView:self];
//
//    if(CGRectContainsPoint(buttonRect, touchLoc)) {
//        addButtonPressed = TRUE;
//        [self setNeedsDisplay];
//    }
//}
//
//
//- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//    if(addButtonPressed) {
//        // Trigger the add callback here.
//        NSLog(@"Add button pressed! Do something now!");
//        [popoverController presentPopoverFromRect:buttonRect inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:true];
//        
//        addButtonPressed = FALSE;
//        [self setNeedsDisplay];
//    }
//}

- (void) setRot:(float) newRot {
    rot = newRot;
}

- (void) setNeedsDisplay {
    [super setNeedsDisplay];
    
    [contentView setNeedsDisplay];
}

- (void) setNeedsLayout {
    [super setNeedsLayout];
    
    [contentView setNeedsLayout];
    
}

- (void) addTopicView:(TopicView *)newTopicView {
    [contentView addSubview:newTopicView];
}

- (void)dealloc {
    [super dealloc];
    [contentView dealloc];
}


@end