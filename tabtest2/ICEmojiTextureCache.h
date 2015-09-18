#import <UIKit/UIKit.h>

@interface ICCustomEmojiTextAttachment : NSTextAttachment
-(ICCustomEmojiTextAttachment*)set_name:(NSString*)name;
-(NSString*)get_name;
@end

@interface ICEmojiTextureCache : NSObject

+(ICEmojiTextureCache*)instance;
-(void)add_image:(UIImage*)image for_name:(NSString*)name;
-(UIImage*)get_image_for_name:(NSString*)name;
-(ICCustomEmojiTextAttachment*)get_image_attachment_for_name:(NSString*)name;
-(NSArray*)get_all_emoji_names;
@end
