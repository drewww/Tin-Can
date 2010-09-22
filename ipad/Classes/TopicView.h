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
	NSString* timeFinished;
	bool isTouched; 
	NSString *text;
	NSString *state;
	NSDateFormatter *timeFormat;
}
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *timeStart;
@property (nonatomic, retain) NSString *timeFinished;
@property (nonatomic, retain) NSString *state;
- (id)initWithFrame:(CGRect)frame withTopic:(Topic *)agenda;
- (id) initWithTopic:(Topic*)theTopic;
@end
