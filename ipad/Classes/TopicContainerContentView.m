//
//  TopicContainerContentView.m
//  TinCan
//
//  Created by Drew Harry on 11/18/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "TopicContainerContentView.h"
#import "TopicView.h"


@implementation TopicContainerContentView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (void)layoutSubviews{
	int i =0;
	NSArray *sortedArray = [[self subviews] sortedArrayUsingSelector:@selector(compareByState:)];
    
    
	for(TopicView *subview in sortedArray){
		
		subview.frame=CGRectMake(7, 6.5 +(56.5*i), (self.bounds.size.width)-14, 50);
        
		i++;
	}
    
   self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 6.5+56.5*i);
    
}

- (void) setNeedsDisplay {
    [super setNeedsDisplay];
    
    for(UIView *v in self.subviews) {
        [v setNeedsDisplay];
    }   
}

- (void)dealloc {
    [super dealloc];
}


@end
