//
//  ICEmojiTextRenderer.h
//  tabtest2
//
//  Created by spotco on 15/09/2015.
//  Copyright (c) 2015 spotco. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICEmojiTextRenderer : NSObject

-(void)set_textview:(UITextView*)textview;

-(void)append_character:(NSString*)str;
-(void)append_emoji:(NSString*)name;

-(void)set_json:(NSString*)json_in;
-(NSString*)get_json;

@end
