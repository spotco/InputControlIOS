
#import "ICEmojiKeyboard.h"

@implementation ICEmojiEntry {
	NSString *_name, *_url;
}
+(ICEmojiEntry*)cons_name:(NSString *)name url:(NSString *)url {
	return [[[ICEmojiEntry alloc] init] i_cons_name:name url:url];
}
-(ICEmojiEntry*)i_cons_name:(NSString *)name url:(NSString *)url {
	_name = name;
	_url = url;
	return self;
}
-(NSString*)get_name { return _name; }
-(NSString*)get_url { return _url; }
@end

@interface ICEmojiKeyboardKey : UIView
+(ICEmojiKeyboardKey*)cons_name:(NSString*)name url:(NSString*)url;
-(void)set_input_listener:(id<ICEmojiInputListener>)listener;
@end
@implementation ICEmojiKeyboardKey {
	UIImageView *_image;
	UILabel *_label;
	
	NSString *_name;
	id<ICEmojiInputListener> _input_listener;
}
+(ICEmojiKeyboardKey*)cons_name:(NSString *)name url:(NSString *)url {
	return [[[ICEmojiKeyboardKey alloc] init] i_cons_name:name url:url];
}
-(ICEmojiKeyboardKey*)i_cons_name:(NSString *)name url:(NSString *)url {
	self.frame = CGRectMake(0, 0, 100, 100);
	self.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
	self.multipleTouchEnabled = NO;
	_name = name;
	
	UIImage *image_data = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
	_image = [[UIImageView alloc] initWithImage:image_data];
	_image.frame = CGRectMake(0, 0, 50, 50);
	_image.center = CGPointMake(self.frame.size.width/2,self.frame.size.height/2 - 10);
	[self addSubview:_image];
	
	_label = [[UILabel alloc] init];
	_label.frame = CGRectMake(0, 0, self.frame.size.width, 20);
	_label.center = CGPointMake(_image.center.x, _image.center.y + 35);
	_label.numberOfLines = 1;
	_label.textAlignment = NSTextAlignmentCenter;
	_label.font = [UIFont systemFontOfSize:14];
	_label.text = name;
    
	[self addSubview:_label];
	
	return self;
}
-(void)set_input_listener:(id<ICEmojiInputListener>)listener {
	_input_listener = listener;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	self.backgroundColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	self.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
	if (CGRectContainsPoint(self.bounds, touchLocation)) {
		[_input_listener emoji_input:_name];
	}
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	self.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
}
@end


@implementation ICEmojiKeyboard {
	UIScrollView *_scroll_view;
	NSMutableArray *_keyboard_keys;
	id<ICEmojiInputListener> _input_listener;
}

-(id)init {
	self = [super init];
	
	self.view = [[UIView alloc] init];
	[self.view setBounds:CGRectMake(0, 0, 0, 200)];
	[self.view setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]];
	
	_scroll_view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 0, 200)];
	[self.view addSubview:_scroll_view];
    _scroll_view.delaysContentTouches = NO;
	
	return self;
}

-(void)i_cons:(NSArray*)emoji_entries {
	if (_keyboard_keys != NULL) return;
	
	CGRect layout_frame = self.view.frame;
	float layout_x = 0;
	float layout_y = 0;
	_keyboard_keys = [NSMutableArray array];
	for (int i = 0; i < emoji_entries.count; i++) {
		ICEmojiEntry *itr_entry = emoji_entries[i];
		ICEmojiKeyboardKey *itr_kbkey = [ICEmojiKeyboardKey cons_name:itr_entry.get_name url:itr_entry.get_url];
		itr_kbkey.frame = CGRectMake(layout_x, layout_y, 100, 100);
		
		if (layout_y > 0) {
			layout_x += itr_kbkey.frame.size.width;
		}
		if (layout_y <= 0) {
			layout_y = 100;
		} else {
			layout_y = 0;
		}
		[_keyboard_keys addObject:itr_kbkey];
		[_scroll_view addSubview:itr_kbkey];
		[itr_kbkey set_input_listener:self];
	}
	_scroll_view.contentSize = CGSizeMake(layout_x+100, layout_frame.size.height);
	_scroll_view.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
	_scroll_view.frame = layout_frame;
}

-(void)emoji_input:(NSString*)name {
	[_input_listener emoji_input:name];
}

-(void)set_input_listener:(id<ICEmojiInputListener>)listener {
	_input_listener = listener;
}

@end
