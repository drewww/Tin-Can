//
//  BackdropView.m
//  TinCan
//
//  Created by Drew Harry on 3/21/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "BackdropView.h"


@implementation BackdropView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.hidden = TRUE;
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Call the delegate and have it do its thing.
    [self.delegate backdropTouchedFrom: self];
}

- (void)dealloc
{
    [super dealloc];
}

@end
