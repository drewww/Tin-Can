//
//  LocationContainerView.m
//  TinCan
//
//  Created by Paula Jacobs on 8/13/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "LocationContainerView.h"
#import "LocationView.h"
#import "StateManager.h"

@implementation LocationContainerView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		self.frame=frame;
		
        
		[self setTransform:CGAffineTransformMakeRotation(M_PI/2)];
		for (Location *loc in  [StateManager sharedInstance].meeting.locations ){
			NSLog(@"location: %@", loc);
			LocationView *newloc = (LocationView *)[loc getView];
		
		NSLog(@"loc: %@", newloc);
		
		
		if([[self subviews]count]<=8){
			[self addSubview:newloc];
		}
		
		
		[self setNeedsLayout];
		}
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);
	CGContextFillRect(ctx, CGRectMake(0, 0, self.bounds.size.width, 22));
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	[@"PARTICIPANTS" drawInRect:CGRectMake(0, 0, self.bounds.size.width, 22) 
				 withFont:[UIFont boldSystemFontOfSize:18] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
	
	CGContextSetLineWidth(ctx,2);
	CGContextSetStrokeColorWithColor(ctx,  [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:1].CGColor);
	CGContextStrokeRect(ctx, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
	
	
}



- (void)layoutSubviews{
	int i =0;
	int c=0;
	NSArray *sortedArray = [[self subviews] sortedArrayUsingSelector:@selector(compareByPointer:)];
	for(LocationView *subview in sortedArray){
		if ( i < 3 ) {
			subview.frame=CGRectMake(5, 27 +(33.25*i), 137.5 , 28.25);

		}
		else{
			subview.frame=CGRectMake(147.5, 27 +(33.25*c), 137.5, 28.25);
			c++;
		}
		//NSLog(@"Frame: %f",self.bounds.size.width);
		//		
		//		NSLog(@"Subview frame: %f",subview.bounds.size.width);
        
        NSLog(@"+++++LAYOUT location.name=%@", subview.location.name);
        
		i++;
	}
    
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch ended on loc container view");
	
	//LocationView *newloc = [LocationView initWithLocation:[[Location alloc] initWithUUID:@"1c40c27d-0765-4746-bde7-fbf8d4325a19"
//										withName:@"Where the party's at, yo. "
//										withMeeting:@"b3dd5d24-408d-4686-bf05-1ac20c05214e"
//										withUsers:[NSMutableSet set]]];
//											
//	NSLog(@"loc: %@", newloc);
//	
//	
//	if([[self subviews]count]<(floor(self.bounds.size.height/100))){
//		[self addSubview:newloc];
//	}
//    [self setNeedsLayout];
}

- (void)dealloc {
    [super dealloc];
}


@end