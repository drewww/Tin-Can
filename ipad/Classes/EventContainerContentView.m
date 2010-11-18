//
//  EventContainerContentView.m
//  TinCan
//
//  Created by Drew Harry on 11/18/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "EventContainerContentView.h"
#import "EventView.h"

@implementation EventContainerContentView

// These shared with TimelineContainerView. 
#define PADDING 5
#define HEIGHT 25
#define HEADER_HEIGHT 22

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {

        
    }
    return self;
}


- (void)layoutSubviews{
	int i=0;
    
	NSArray *sortedArray = [[self subviews] sortedArrayUsingSelector:@selector(compareByTime:)];
    
    NSLog(@"sorted subview array: %@", sortedArray);
    
    // This is not the right layout, but we'll leave it that way for now until we 
    // actually figure out what EventViews will look like.
	for(EventView *subview in [sortedArray reverseObjectEnumerator]){
        subview.frame=CGRectMake(PADDING, PADDING+(HEIGHT*i) + (PADDING*(i)), self.bounds.size.width-(PADDING*2), HEIGHT);        
        NSLog(@"   EventView.frame: %@", NSStringFromCGRect(subview.frame));
        i++;
	}
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, (HEIGHT*i) + (PADDING*(i+1)));
    
    NSLog(@"event container: %@", NSStringFromCGRect(self.frame));
    // update the container with the new bounds.
    
    UIScrollView *parentScrollView;
    
    if([self.superview isKindOfClass:[UIScrollView class]]) {
        parentScrollView = (UIScrollView *)self.superview;
        parentScrollView.contentSize = self.bounds.size;
    }
    
}


- (void)dealloc {
    [super dealloc];
}


@end
