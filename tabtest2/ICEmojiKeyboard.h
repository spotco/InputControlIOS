#import <UIKit/UIKit.h>

@protocol ICEmojiInputListener <NSObject>
@required
-(void)emoji_input:(NSString*)name;
@end

@interface ICEmojiEntry : NSObject
+(ICEmojiEntry*)cons_name:(NSString*)name;
-(NSString*)get_name;
@end

@interface ICEmojiKeyboard : UIViewController <ICEmojiInputListener>
-(void)i_cons:(NSArray*)emoji_entries;
-(void)set_input_listener:(id<ICEmojiInputListener>)listener;
@end
