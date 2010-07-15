//
//  LogoView.m
//  Login
//
//  Created by Paula Jacobs on 6/29/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import "LogoView.h"


@implementation LogoView


- (id)initWithImage:(UIImage *)image withFrame:(CGRect)frame{
    if ((self = [super initWithImage:image])) {
       
		[self setNeedsDisplay];
		self.frame = frame;
		
		
    }
	return self;  
}

- (void)dealloc {
    [super dealloc];
}


@end
