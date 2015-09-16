#import "ICEmojiTextRenderer.h"
#import "ICEmojiTextureCache.h"

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
	[self _insert_emoji_in_range:range with_name:name];
	[self render_text];
}
-(void)_insert_emoji_in_range:(NSRange)range with_name:(NSString*)name {
	NSAttributedString *emoji = [NSAttributedString attributedStringWithAttachment:[[ICEmojiTextureCache instance] get_image_attachment_for_name:@"HighFive"]];
    [_str_buf replaceCharactersInRange:range withAttributedString:emoji];
}
-(void)replace_characters_in_range:(NSRange)range with_string:(NSString *)string {
	[self _replace_characters_in_range:range with_string:string];
    [self render_text];
}
-(void)_replace_characters_in_range:(NSRange)range with_string:(NSString *)string {
	[_str_buf replaceCharactersInRange:range withAttributedString:[[NSAttributedString alloc] initWithString:string attributes:_font_attr_dict]];
}

-(void)set_json:(NSString*)json_in {
	[_str_buf replaceCharactersInRange:NSMakeRange(0, _str_buf.length) withString:@""];
	NSError *e;
	NSArray *screenplay_line_tokens = [NSJSONSerialization JSONObjectWithData:[json_in dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&e];
	for (int i = 0; i < screenplay_line_tokens.count; i++) {
		NSDictionary *itr = screenplay_line_tokens[i];
		NSString *type = itr[@"type"];
		NSString *val = itr[@"val"];
		if ([type isEqualToString:@"text"]) {
			[self _replace_characters_in_range:NSMakeRange(_str_buf.length, 0) with_string:val];
		} else if ([type isEqualToString:@"emoji"]) {
			[self _insert_emoji_in_range:NSMakeRange(_str_buf.length, 0) with_name:val];
		}
	}
	[self render_text];
}

-(NSString*)get_json {
	NSMutableArray *rtv = [NSMutableArray array];
	NSMutableString *buf = [NSMutableString stringWithString:@""];
	for (int i = 0; i < _str_buf.length; i++) {
		NSRange range;
		NSDictionary *attrs = [_str_buf attributesAtIndex:i effectiveRange:&range];
		if (attrs[NSAttachmentAttributeName] != NULL) {
			if (buf.length > 0) {
				[rtv addObject:@{@"type":@"text",@"val":[NSString stringWithString:buf]}];
				buf = [NSMutableString stringWithString:@""];
			}
			
			ICCustomEmojiTextAttachment *emoji_attachment = attrs[NSAttachmentAttributeName];
			[rtv addObject:@{@"type":@"emoji",@"val":emoji_attachment.get_name}];
			
		} else {
			[buf appendString:[_str_buf.string substringWithRange:NSMakeRange(i, 1)]];
		}
	}
	if (buf.length > 0) {
		[rtv addObject:@{@"type":@"text",@"val":[NSString stringWithString:buf]}];
	}
	
	NSError *error;
	NSData *data = [NSJSONSerialization dataWithJSONObject:rtv options:0 error:&error];
	return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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
