//
//  TopicView.h
//  TinCan
//
//  Created by Paula Jacobs on 8/11/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Topic.h"
#import "ManageTopicController.h"

@interface TopicView : UIView <ManageTopicDelegate> {
	Topic *topic;
	bool isTouched; 
	NSDateFormatter *timeFormat;
    
    CGFloat optionSliderX;
    
    UIPopoverController *manageTopicPopover;
}

@property (nonatomic, retain) Topic *topic;

- (int) getSelectedButton;
- (id)initWithFrame:(CGRect)frame withTopic:(Topic *)theTopic;
- (id)initWithTopic:(Topic*)theTopic;
@end
