//
//  ICEmojiTextRenderer.m
//  tabtest2
//
//  Created by spotco on 15/09/2015.
//  Copyright (c) 2015 spotco. All rights reserved.
//

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
}

-(id)init {
	self = [super init];
	
	NSDictionary *font_attr_dict = @{ NSFontAttributeName : [UIFont systemFontOfSize:20] };
	_str_buf = [[NSMutableAttributedString alloc] initWithString:@"test" attributes:font_attr_dict];
	
	return self;
}

-(void)set_textview:(UITextView*)textview {
	_textview = textview;
}

-(void)append_character:(NSString*)str {

}

-(void)append_emoji:(NSString*)name {
	UIImage *image_data = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://spotcos.com/et/highfive.png"]]];
	NSTextAttachment *image_attachment = [[ICCustomEmojiTextAttachment alloc] init];
	[image_attachment setImage:[UIImage imageWithCGImage:image_data.CGImage scale:10 orientation:UIImageOrientationUp]];
	NSAttributedString *emoji = [NSAttributedString attributedStringWithAttachment:image_attachment];
	[_str_buf appendAttributedString:emoji];
	
	[_textview setAttributedText:_str_buf];
}

-(void)set_json:(NSString*)json_in {

}

-(NSString*)get_json {
	return @"";
}

@end
