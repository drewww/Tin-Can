//
//  TopicContainerView.m
//  TinCan
//
//  Created by Paula Jacobs on 8/11/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "TopicContainerView.h"
#import "TopicView.h"

@implementation TopicContainerView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.frame=frame;
		
        rot = M_PI/2;
		[self setTransform:CGAffineTransformMakeRotation(rot)];
		
		
		[self setNeedsLayout];
		
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);
	CGContextFillRect(ctx, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height/22.0));
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	[@"TOPICS" drawInRect:CGRectMake(0, self.bounds.size.height/150.0, self.bounds.size.width, self.bounds.size.height/25.0 - self.bounds.size.height/100.0) 
                withFont:[UIFont boldSystemFontOfSize:self.bounds.size.height/33.3] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	
	CGContextSetLineWidth(ctx,2);
	CGContextSetStrokeColorWithColor(ctx,  [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);
	CGContextStrokeRect(ctx, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
	
	
}

- (void) setRot:(float) newRot {
    rot = newRot;
}


- (void)layoutSubviews{
	int i =0;
	NSArray *sortedArray = [[self subviews] sortedArrayUsingSelector:@selector(compareByPointer:)];
	for(TopicView *subview in sortedArray){
		subview.frame=CGRectMake(10, 40+(60*i), (self.bounds.size.width)-20, 50);
		//NSLog(@"Frame: %f",self.bounds.size.width);
//		
//		NSLog(@"Subview frame: %f",subview.bounds.size.width);
		i++;
	}
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch ended on task container view");
   
	Topic *newTopic = [[Topic alloc] initWithUUID:@"1c40c27d-0765-4746-bde7-fbf8d4325a19"
												withText:@"Rawr, new topic"
										 withCreatorUUID:@"b3dd5d24-408d-4686-bf05-1ac20c05214e"
											   createdAt:[NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]-600]
										 withMeetingUUID:@"07823bd0-212e-444e-a7b8-c3a4eb3a1392"
									  withStartActorUUID:@"183ebc3a-9c8c-44a4-a2e4-a1f36b19c48f"
									   withStopActorUUID:@"ba5082c9-6fd2-489f-8768-4eca94420ed0"
										   withStartTime:[NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]-400]
											withStopTime:[NSDate dateWithTimeIntervalSince1970:[[NSDate date] timeIntervalSince1970]-200]
										  withUIColor:[UIColor blueColor]];
	
	NSLog(@"topic: %@", newTopic);
	
	TopicView *newTopicView = [newTopic getView];
	
	if([[self subviews]count]<(floor(self.bounds.size.height/66.0))){
		[self addSubview:newTopicView];
	}
    [self setNeedsLayout];
}

- (void)dealloc {
    [super dealloc];
}


@end