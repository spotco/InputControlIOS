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
    NSMutableDictionary *_name_to_uiimage;
    NSMutableDictionary *_name_to_attachment;
}

static ICEmojiTextureCache *__instance;
+(ICEmojiTextureCache*)instance {
    if (__instance == NULL) __instance = [[ICEmojiTextureCache alloc] init];
    return __instance;
}

-(id)init {
    self = [super init];
    _name_to_uiimage = [NSMutableDictionary dictionary];
    _name_to_attachment = [NSMutableDictionary dictionary];
    return self;
}

-(void)add_image_data:(Byte*)data length:(long)length for_name:(NSString*)name {
    NSData *image_data = [[NSData alloc] initWithBytes:(void*)data length:length];
    UIImage *image = [[UIImage alloc] initWithData:image_data];
    [self add_image:image for_name:name];
}

-(void)add_image:(UIImage*)image for_name:(NSString*)name {
    _name_to_uiimage[name] = image;
	NSTextAttachment *image_attachment = [[[ICCustomEmojiTextAttachment alloc] init] set_name:name];
	[image_attachment setImage:[UIImage imageWithCGImage:image.CGImage scale:12 orientation:UIImageOrientationUp]];
    
    _name_to_attachment[name] = image_attachment;
}

-(UIImage*)get_image_for_name:(NSString*)name {
    return _name_to_uiimage[name];
}

-(ICCustomEmojiTextAttachment*)get_image_attachment_for_name:(NSString*)name {
    return _name_to_attachment[name];
}

-(NSArray*)get_all_emoji_names {
    NSMutableArray *rtv = [NSMutableArray array];
    for (NSString *key in _name_to_uiimage.keyEnumerator) {
        [rtv addObject:key];
    }
    return rtv;
}

@end
