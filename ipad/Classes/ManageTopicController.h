//
//  ManageTopicController.h
//  TinCan
//
//  Created by Drew Harry on 3/28/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Topic.h";

@protocol ManageTopicDelegate
- (void) startTopic;
- (void) stopTopic;
- (void) deleteTopic;
@end

@interface ManageTopicController : UIViewController {
    
    Topic *topic;
    
    UIButton *startTopicButton;
    UIButton *stopTopicButton;
    UIButton *deleteTopicButton;
    
    id <ManageTopicDelegate> delegate;
}

- (id)initWithTopic:(Topic *)theTopic;
- (void) startButtonPressed;
- (void) stopButtonPressed;
- (void) deleteButtonPressed;


@property (nonatomic, assign) id <ManageTopicDelegate> delegate;

@end
