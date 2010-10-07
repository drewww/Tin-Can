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
	bool isTouched; 
	NSDateFormatter *timeFormat;
}

@property (nonatomic, retain) Topic *topic;

- (id)initWithFrame:(CGRect)frame withTopic:(Topic *)theTopic;
- (id)initWithTopic:(Topic*)theTopic;
@end
