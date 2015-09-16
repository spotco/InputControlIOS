#import "ICEmojiTextureCache.h"

@implementation ICCustomEmojiTextAttachment {
	NSString *_name;
}
-(CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    CGRect bounds;
    bounds.origin = CGPointMake(0, -5);
    bounds.size = self.image.size;
    return bounds;
}
-(ICCustomEmojiTextAttachment*)set_name:(NSString*)name {
	_name = name;
	return self;
}
-(NSString*)get_name {
	return _name;
}
@end

@implementation ICEmojiTextureCache {
    NSMutableDictionary *_url_to_uiimage;
    NSMutableDictionary *_url_to_attachment;
}

static ICEmojiTextureCache *__instance;
+(ICEmojiTextureCache*)instance {
    if (__instance == NULL) __instance = [[ICEmojiTextureCache alloc] init];
    return __instance;
}

-(id)init {
    self = [super init];
    _url_to_uiimage = [NSMutableDictionary dictionary];
    _url_to_attachment = [NSMutableDictionary dictionary];
    return self;
}

-(void)add_image:(UIImage*)image for_name:(NSString*)name {
    _url_to_uiimage[name] = image;

	NSTextAttachment *image_attachment = [[[ICCustomEmojiTextAttachment alloc] init] set_name:name];
	[image_attachment setImage:[UIImage imageWithCGImage:image.CGImage scale:12 orientation:UIImageOrientationUp]];
    
    _url_to_attachment[name] = image_attachment;
}

-(UIImage*)get_image_for_name:(NSString*)name {
    return _url_to_uiimage[name];
}

-(ICCustomEmojiTextAttachment*)get_image_attachment_for_name:(NSString*)name {
    return _url_to_attachment[name];
}

@end
