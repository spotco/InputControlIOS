#import <UIKit/UIKit.h>
#import "ICEmojiKeyboard.h"
#import "ICEmojiTextRenderer.h"

@interface ICRootViewController : UIViewController <UITextViewDelegate,ICEmojiInputListener>
+(ICRootViewController*)context;

-(void)toggle_native_control_ui:(BOOL)val;
-(void)load_message_json:(NSString*)messageJSON;
-(NSString*)out_message_json;
-(NSString*)input_view_size_json;
-(NSString*)getc_input_button_presses;
-(void)enqueue_button_press:(NSString*)name;
-(void)delete_button_pressed;
@end
