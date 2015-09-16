//
//  ControlBarUIViewController.h
//  tabtest
//
//  Created by Shiny Yang on 9/3/15.
//  Copyright (c) 2015 spotco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICEmojiKeyboard.h"
#import "ICEmojiTextRenderer.h"

@interface ControlBarUIViewController : UIViewController <UITextViewDelegate,ICEmojiInputListener>

-(void)toggle_native_control_ui:(BOOL)val;
-(void)load_message_json:(NSString *)messageJSON;
-(NSString*)out_message_json;

@end
