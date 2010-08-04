//
//  TaskView.h
//  TinCan
//
//  Created by Paula Jacobs on 8/3/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TaskView : UIView {
	NSString *text;
	CGPoint    initialOrigin;

}
- (id)initWithFrame:(CGRect)frame withText:(NSString *)task;
@end
