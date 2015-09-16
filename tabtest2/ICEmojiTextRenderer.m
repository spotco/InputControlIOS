#import "ICEmojiTextRenderer.h"

@interface ICCustomEmojiTextAttachment : NSTextAttachment
@end
@implementation ICCustomEmojiTextAttachment
- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {
    CGRect bounds;
    bounds.origin = CGPointMake(0, -5);
    bounds.size = self.image.size;
    return bounds;
}
@end

@implementation ICEmojiTextRenderer {
	NSMutableAttributedString *_str_buf;
	UITextView *_textview;
    
    NSDictionary *_font_attr_dict;
}
    
-(id)init {
	self = [super init];
	_font_attr_dict = @{ NSFontAttributeName : [UIFont systemFontOfSize:20] };
	_str_buf = [[NSMutableAttributedString alloc] initWithString:@"" attributes:_font_attr_dict];
	return self;
}

-(void)render_text {
    [_textview setAttributedText:_str_buf];
}

-(void)set_textview:(UITextView*)textview {
	_textview = textview;
    [self render_text];
}

-(void)insert_emoji_in_range:(NSRange)range with_name:(NSString*)name {
	UIImage *image_data = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://spotcos.com/et/highfive.png"]]];
	NSTextAttachment *image_attachment = [[ICCustomEmojiTextAttachment alloc] init];
	[image_attachment setImage:[UIImage imageWithCGImage:image_data.CGImage scale:12 orientation:UIImageOrientationUp]];
	NSAttributedString *emoji = [NSAttributedString attributedStringWithAttachment:image_attachment];
    [_str_buf replaceCharactersInRange:range withAttributedString:emoji];
	[self render_text];
}

-(void)replace_characters_in_range:(NSRange)range with_string:(NSString *)string {
    [_str_buf replaceCharactersInRange:range withAttributedString:[[NSAttributedString alloc] initWithString:string attributes:_font_attr_dict]];
    [self render_text];
}

-(void)set_json:(NSString*)json_in {}

-(NSString*)get_json {
	return @"";
}

-(NSAttributedString*)get_attributed_string {
    return _str_buf;
}

-(CGRect)get_text_bounds_for_width:(float)wid {
    return [self.get_attributed_string boundingRectWithSize:CGSizeMake(wid, CGFLOAT_MAX)
                                                                        options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                                        context:nil];
}

@end
