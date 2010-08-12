//
//  TopicView.h
//  TinCan
//
//  Created by Paula Jacobs on 8/11/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Topic.h"

@interface TopicView : UIView {
	Topic *topic;
	NSString* timeStart;
	bool isTouched; 
	NSString *text;
	NSDateFormatter *timeFormat;
}
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *timeStart;

- (id)initWithFrame:(CGRect)frame withTopic:(Topic *)agenda;
- (id)initWithFrame:(CGRect)frame withText:(NSString *)words withStartTime:(NSDate *)date;
@end
