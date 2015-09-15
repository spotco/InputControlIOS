//
//  ICEmojiKeyboard.h
//  tabtest2
//
//  Created by spotco on 15/09/2015.
//  Copyright (c) 2015 spotco. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ICEmojiInputListener <NSObject>
@required
-(void)emoji_input:(NSString*)name;
@end

@interface ICEmojiEntry : NSObject
+(ICEmojiEntry*)cons_name:(NSString*)name url:(NSString*)url;
-(NSString*)get_name;
-(NSString*)get_url;
@end

@interface ICEmojiKeyboard : UIViewController <ICEmojiInputListener>
-(void)i_cons:(NSArray*)emoji_entries;
-(void)set_input_listener:(id<ICEmojiInputListener>)listener;
@end