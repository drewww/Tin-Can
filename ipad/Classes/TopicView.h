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
	NSString *text;
}
@property (nonatomic, retain) NSString *text;
- (id)initWithFrame:(CGRect)frame withTopic:(Topic *)agenda;
- (id)initWithFrame:(CGRect)frame withText:(NSString *)words;
@end
