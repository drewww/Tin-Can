//
//  AddUserButton.m
//  TinCan
//
//  Created by Drew Harry on 12/8/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "AddUserButton.h"

#define COLOR [UIColor colorWithWhite:0.3 alpha:1]
#define BUTTON_COLOR [UIColor colorWithWhite:0.6 alpha:1]
#define BUTTON_PRESSED_COLOR [UIColor colorWithWhite:0.45 alpha:1]


@implementation AddUserButton


- (id)init {
    
    self = [super initWithFrame:CGRectMake(0, 0, 20, 20)];
    if (self) {
        buttonPressed = NO;
        
        AddUserController *addUserController = [[AddUserController alloc] init];
        addUserController.delegate = self;
        
        addUserPopover = [[[UIPopoverController alloc] initWithContentViewController:addUserController] retain];        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    if(buttonPressed) {
        CGContextSetFillColorWithColor(ctx, BUTTON_PRESSED_COLOR.CGColor);
    } else {
        CGContextSetFillColorWithColor(ctx, BUTTON_COLOR.CGColor);   
    }
    CGContextFillRect(ctx, self.bounds);
    
    CGContextSetFillColorWithColor(ctx, COLOR.CGColor);
    CGContextFillRect(ctx, CGRectInset(self.bounds, 9, 2));
    CGContextFillRect(ctx, CGRectInset(self.bounds, 2, 9));
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    buttonPressed = YES;
    NSLog(@"button pressed!");
    [self setNeedsDisplay];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    if(buttonPressed) {
        NSLog(@"about to present popover: %@", addUserPopover);
        [addUserPopover presentPopoverFromRect:self.bounds inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        NSLog(@"presented popover");
    }
    
    buttonPressed = NO;
    [self setNeedsDisplay];
    NSLog(@"out of touches ended");
}

- (void) userSelected:(User *)userToAdd {
    NSLog(@"user selected: %@", userToAdd);
    
    [addUserPopover dismissPopoverAnimated:YES];
}

- (void)dealloc {
    [super dealloc];
    [addUserPopover release];
}


@end
