//
//  TopicContainerView.h
//  TinCan
//
//  Created by Paula Jacobs on 8/11/10.
//  Copyright 2010 MIT Media Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopicContainerContentView.h"

@interface TopicContainerView : UIView {
	float rot;    
    
    TopicContainerContentView *contentView;
    UIScrollView *topicScrollView;
    
    CGRect buttonRect;
    bool addButtonPressed;
    
    UIPopoverController *popoverController;
}

- (void) addTopicView:(UIView *)newTopicView;

@end
