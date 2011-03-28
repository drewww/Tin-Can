//
//  ManageTopicController.h
//  TinCan
//
//  Created by Drew Harry on 3/28/11.
//  Copyright 2011 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ManageTopicDelegate
- (void) startTopic;
- (void) stopTopic;
- (void) deleteTopic;
@end

@interface ManageTopicController : UIViewController {
    
    UIButton *startTopicButton;
    UIButton *stopTopicButton;
    UIButton *deleteTopicButton;
    
    id <ManageTopicDelegate> delegate;
}

@property (nonatomic, assign) id <ManageTopicDelegate> delegate;

@end
