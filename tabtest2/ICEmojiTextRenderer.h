#import <UIKit/UIKit.h>

@interface ICEmojiTextRenderer : NSObject

-(void)set_textview:(UITextView*)textview;

-(void)render_text;

-(void)insert_emoji_in_range:(NSRange)range with_name:(NSString*)name;
-(void)replace_characters_in_range:(NSRange)range with_string:(NSString*)string;

-(void)set_json:(NSString*)json_in;
-(NSString*)get_json;
-(NSAttributedString*)get_attributed_string;

-(CGRect)get_text_bounds_for_width:(float)wid;

@end
