//
//  TrashView.m
//  TinCan
//
//  Created by Drew Harry on 2/28/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import "TrashView.h"
#import "UIView+Rounded.h"


@implementation TrashView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        isHovered = false;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    
}

- (void) setHoverState:(bool)state {
    isHovered = state;
}

- (void)dealloc {
    [super dealloc];
}


@end
