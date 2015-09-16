
#import "ICEmojiKeyboard.h"
#import "ICButton.h"
#import "ICEmojiTextureCache.h"

@implementation ICEmojiEntry {
	NSString *_name;
}
+(ICEmojiEntry*)cons_name:(NSString *)name {
	return [[[ICEmojiEntry alloc] init] i_cons_name:name];
}
-(ICEmojiEntry*)i_cons_name:(NSString *)name {
	_name = name;
	return self;
}
-(NSString*)get_name { return _name; }
@end

@interface ICEmojiKeyboardKey : UIView
+(ICEmojiKeyboardKey*)cons_name:(NSString *)name;
-(void)set_input_listener:(id<ICEmojiInputListener>)listener;
@end
@implementation ICEmojiKeyboardKey {
	UIImageView *_image;
	UILabel *_label;
	
	NSString *_name;
	id<ICEmojiInputListener> _input_listener;
}
+(ICEmojiKeyboardKey*)cons_name:(NSString *)name {
	return [[[ICEmojiKeyboardKey alloc] init] i_cons_name:name];
}
-(ICEmojiKeyboardKey*)i_cons_name:(NSString *)name {
	self.frame = CGRectMake(0, 0, 75, 75);
	self.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
	self.multipleTouchEnabled = NO;
	_name = name;
	
	UIImage *image_data = [[ICEmojiTextureCache instance] get_image_for_name:name];
    _image = [[UIImageView alloc] initWithImage:image_data];
	_image.frame = CGRectMake(0, 0, 50, 50);
	_image.center = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
	[self addSubview:_image];
	
	_label = [[UILabel alloc] init];
	_label.frame = CGRectMake(0, 0, self.frame.size.width, 20);
	_label.center = CGPointMake(_image.center.x, _image.center.y + 30);
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
    
    ICImageButton *_add_dialogue_left_button;
    ICImageButton *_add_dialogue_right_button;
    ICImageButton *_delete_button;
}

-(id)init {
	self = [super init];
	
	self.view = [[UIView alloc] init];
	[self.view setBounds:CGRectMake(0, 0, 0, 200)];
	[self.view setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]];
	
	_scroll_view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 50, 0, 150)];
	[self.view addSubview:_scroll_view];
    _scroll_view.delaysContentTouches = NO;
	
	return self;
}

-(void)i_cons:(NSArray*)emoji_entries {
	if (_keyboard_keys != NULL) return;
    
    _add_dialogue_left_button = [[ICImageButton alloc] initWithFrame:CGRectMake(0, 3.75, 50, 42.5)];
    [_add_dialogue_left_button set_image:[[UIImage imageNamed:@"ic_keyboard_add_dialogue_bubble"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [_add_dialogue_left_button set_pressed:[Callback cons_id:self selector:@selector(add_dialogue_left_pressed)]];
    [self.view addSubview:_add_dialogue_left_button];
    
    _add_dialogue_right_button = [[ICImageButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50, 3.75, 50, 42.5)];
    [_add_dialogue_right_button set_image:[[UIImage imageNamed:@"ic_keyboard_add_dialogue_bubble"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
	[_add_dialogue_right_button set_pressed:[Callback cons_id:self selector:@selector(add_dialogue_right_pressed)]];
    [_add_dialogue_right_button img_scale_x:-1 y:1];
    [self.view addSubview:_add_dialogue_right_button];
    
    _delete_button = [[ICImageButton alloc] initWithFrame:CGRectMake(_add_dialogue_right_button.frame.origin.x-55, 10, 45, 30)];
    [_delete_button set_image:[[UIImage imageNamed:@"ic_keyboard_delete"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [_delete_button set_pressed:[Callback cons_id:self selector:@selector(delete_pressed)]];
    [_delete_button set_color_neutral:[UIColor colorWithRed:0.39 green:0.39 blue:0.39 alpha:1] down:[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1]];
    [self.view addSubview:_delete_button];
    
	CGRect scroll_layout_frame = CGRectMake(_scroll_view.frame.origin.x, _scroll_view.frame.origin.y, self.view.frame.size.width, _scroll_view.frame.size.height);
	float layout_x = 0;
	float layout_y = 0;
	_keyboard_keys = [NSMutableArray array];
	for (int i = 0; i < emoji_entries.count; i++) {
		ICEmojiEntry *itr_entry = emoji_entries[i];
		ICEmojiKeyboardKey *itr_kbkey = [ICEmojiKeyboardKey cons_name:itr_entry.get_name];
		itr_kbkey.frame = CGRectMake(layout_x, layout_y, itr_kbkey.frame.size.width, itr_kbkey.frame.size.height);
		
		if (layout_y > 0) {
			layout_x += itr_kbkey.frame.size.width;
		}
		if (layout_y <= 0) {
			layout_y = itr_kbkey.frame.size.height;
		} else {
			layout_y = 0;
		}
		[_keyboard_keys addObject:itr_kbkey];
		[_scroll_view addSubview:itr_kbkey];
		[itr_kbkey set_input_listener:self];
	}
	_scroll_view.contentSize = CGSizeMake(layout_x+75, scroll_layout_frame.size.height);
	_scroll_view.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
	_scroll_view.frame = scroll_layout_frame;
}

-(void)add_dialogue_left_pressed {
    NSLog(@"dialogue_left_pressed");
}

-(void)add_dialogue_right_pressed {
    NSLog(@"dialogue_right_pressed");
}

-(void)delete_pressed {
    NSLog(@"delete");
}

-(void)emoji_input:(NSString*)name {
	[_input_listener emoji_input:name];
}

-(void)set_input_listener:(id<ICEmojiInputListener>)listener {
	_input_listener = listener;
}

@end
