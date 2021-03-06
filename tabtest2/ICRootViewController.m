#import "ICRootViewController.h"

#ifndef COMPILE_WO_UNITY
#import "UnityView.h"
#import "UnityAppController+ViewHandling.h"
#endif

#import "ICButton.h"
#import "ICEmojiTextureCache.h"
#import "ICUtil.h"


typedef enum _KeyboardMode {
    KeyboardMode_Closed,
    KeyboardMode_Open,
    KeyboardMode_OpenToClose,
    KeyboardMode_CloseToOpen
} KeyboardMode;

@implementation ICRootViewController {
    UITextView *_root_activaton_textview;
    UIView *_accessoryview_root;
    UITextView *_accessoryview_textview;
    CGRect _input_view_screen_rect;
    NSTimer *_update_timer;
    double _keyboard_animation_duration;
    double _keyboard_animation_t; //0 closed, _keyboard_aniation_duration open
    KeyboardMode _keyboard_mode;
    NSTimeInterval _last_update_time;
	
	ICEmojiKeyboard *_emoji_keyboard;
	ICEmojiTextRenderer *_emoji_text_renderer;
    
    ICLabelButton *_done_button;
    
    UIView *_controlbar_mode_selection;
    ICImageButton *_controlbar_text_button;
    ICImageButton *_controlbar_mic_button;
    ICImageButton *_controlbar_emoji_button;
    UIView *_bottom_border;
    
    NSMutableArray *_enqueued_button_presses;
}

static ICRootViewController *_context;
+(ICRootViewController*)context { return _context; }
-(void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    _input_view_screen_rect = [value CGRectValue];
    if ([notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] != 0) {
        _keyboard_animation_duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    }
}
-(void)keyboardDidHide:(NSNotification*)notification {
    _input_view_screen_rect = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, 0, 0);
}
-(NSString*)input_view_size_json {
    NSError *error;
    NSString *rtv = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@{
        @"x":[NSString stringWithFormat:@"%d",(int)_input_view_screen_rect.origin.x],
        @"y":[NSString stringWithFormat:@"%d",(int)_input_view_screen_rect.origin.y],
        @"w":[NSString stringWithFormat:@"%d",(int)_input_view_screen_rect.size.width],
        @"h":[NSString stringWithFormat:@"%d",(int)(_input_view_screen_rect.size.height *
            bezier_point_for_t(
                CGPointMake(0, 0),
                CGPointMake(0.5, 0),
                CGPointMake(0.5, 1),
                CGPointMake(1, 1),
                (_keyboard_animation_t/_keyboard_animation_duration)
            ).y
        )],
        @"sw":[NSString stringWithFormat:@"%d",(int)[[UIScreen mainScreen] bounds].size.width],
        @"sh":[NSString stringWithFormat:@"%d",(int)[[UIScreen mainScreen] bounds].size.height]
    } options:0 error:&error] encoding:NSUTF8StringEncoding];
    return rtv;
}

-(void)viewDidAppear:(BOOL)animated {
    _enqueued_button_presses = [NSMutableArray array];
    
    _context = self;
    _last_update_time = [NSDate timeIntervalSinceReferenceDate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:NULL];
    
    _update_timer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(update) userInfo:NULL repeats:YES];
    _keyboard_mode = KeyboardMode_Closed;
    _keyboard_animation_duration = 0.5;
    
    [super viewDidAppear:animated];
#ifndef COMPILE_WO_UNITY
    [self.view addSubview:((UnityAppController*)[UIApplication sharedApplication].delegate).unityView];
#endif

    _root_activaton_textview = [[UITextView alloc] initWithFrame:CGRectMake(0,0,0,0)];
	
    _accessoryview_textview = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width - 60, 25)];
    _accessoryview_textview.textContainer.lineBreakMode = NSLineBreakByCharWrapping;
    [_accessoryview_textview setFont:[UIFont systemFontOfSize:20]];
    _accessoryview_textview.textContainer.lineFragmentPadding = 0;
    _accessoryview_textview.textContainerInset = UIEdgeInsetsMake(3, 3, 3, 3);
    _accessoryview_textview.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    
    [_accessoryview_textview setDelegate:self];
    [_root_activaton_textview setDelegate:self];
    
    _accessoryview_root = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 50)];
    _accessoryview_root.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    _accessoryview_root.clipsToBounds = YES;
    _accessoryview_root.autoresizesSubviews = NO;
    
    [_accessoryview_root addSubview:_accessoryview_textview];
    
    _root_activaton_textview.inputAccessoryView = _accessoryview_root;
    _accessoryview_textview.inputAccessoryView = _accessoryview_root;
    _root_activaton_textview.keyboardType = UIKeyboardTypeASCIICapable;
    _accessoryview_textview.keyboardType = UIKeyboardTypeASCIICapable;
    
    [self.view addSubview:_root_activaton_textview];
    
    _controlbar_mode_selection = [[UIView alloc] initWithFrame:CGRectMake(0, 25, [UIScreen mainScreen].bounds.size.width, 30)];
    [_accessoryview_root addSubview:_controlbar_mode_selection];
    
    _controlbar_emoji_button = [[ICImageButton alloc] init];
    [_controlbar_emoji_button set_image:[[UIImage imageNamed:@"ic_bar_icon_emoji"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [_controlbar_emoji_button setFrame:CGRectMake(0, 0, 30, 30)];
    [_controlbar_emoji_button set_pressed:[Callback cons_id:self selector:@selector(controlbar_option_emojimode)]];
    [_controlbar_mode_selection addSubview:_controlbar_emoji_button];
    
    _controlbar_mic_button = [[ICImageButton alloc] init];
    [_controlbar_mic_button set_image:[[UIImage imageNamed:@"ic_bar_icon_mic"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [_controlbar_mic_button setFrame:CGRectMake(35, 0, 30, 30)];
    [_controlbar_mic_button set_pressed:[Callback cons_id:self selector:@selector(controlbar_option_recordmode)]];
    [_controlbar_mode_selection addSubview:_controlbar_mic_button];
    
    _controlbar_text_button = [[ICImageButton alloc] init];
    [_controlbar_text_button set_image:[[UIImage imageNamed:@"ic_bar_icon_text"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [_controlbar_text_button setFrame:CGRectMake(70, 0, 30, 30)];
    [_controlbar_text_button set_pressed:[Callback cons_id:self selector:@selector(controlbar_option_textmode)]];
    [_controlbar_mode_selection addSubview:_controlbar_text_button];
    
	_emoji_keyboard = [[ICEmojiKeyboard alloc] init];
	[_emoji_keyboard set_input_listener:self];
	
	_emoji_text_renderer = [[ICEmojiTextRenderer alloc] init];
	[_emoji_text_renderer set_textview:_accessoryview_textview];
    [_emoji_text_renderer replace_characters_in_range:NSMakeRange(0, 0) with_string:@""];
    
    _done_button = [[ICLabelButton alloc] init];
    _done_button.frame = CGRectMake(0, 0, 50, 50);
    [_done_button set_label:@"Done"];
    [_done_button set_pressed:[Callback cons_id:self selector:@selector(done_button_press)]];
    [_accessoryview_root addSubview:_done_button];
    
    _bottom_border = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _controlbar_mode_selection.frame.size.width, 2)];
    [_bottom_border setBackgroundColor:[UIColor colorWithRed:0.74 green:0.74 blue:0.74 alpha:1]];
    [_accessoryview_root addSubview:_bottom_border];
    
    [self recalculate_textview_layout];
}

-(void)update {
    NSTimeInterval current_time = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval delta_time = current_time-_last_update_time;
    
    switch (_keyboard_mode) {
    case KeyboardMode_OpenToClose:{
        _keyboard_animation_t -= delta_time;
        if (_keyboard_animation_t <= 0) {
            _keyboard_mode = KeyboardMode_Closed;
        }
    } break;
    case KeyboardMode_CloseToOpen:{
        _keyboard_animation_t += delta_time;
        if (_keyboard_animation_t >= _keyboard_animation_duration) {
            _keyboard_mode = KeyboardMode_Open;
        }
    } break;
    case KeyboardMode_Open:{} break;
    case KeyboardMode_Closed:{} break;
    }
    _keyboard_animation_t = clampf(_keyboard_animation_t,0,_keyboard_animation_duration);
    _last_update_time = current_time;
}

-(void)emoji_input:(NSString *)name {
    NSRange pre_range = _accessoryview_textview.selectedRange;
    [_emoji_text_renderer insert_emoji_in_range:pre_range with_name:name];
    [self recalculate_textview_layout];
    [_accessoryview_textview setSelectedRange:NSMakeRange(pre_range.location+1, 0)];
}

static bool __rentrant_lock = NO;
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (__rentrant_lock == NO) {
        __rentrant_lock = YES;
        if ([_root_activaton_textview isFirstResponder] && [_accessoryview_textview canBecomeFirstResponder]) {
            [_root_activaton_textview resignFirstResponder];
            [_accessoryview_textview becomeFirstResponder];
            range = NSMakeRange(_accessoryview_textview.attributedText.length, 0);
            [_accessoryview_textview setSelectedRange:range];
            [_emoji_text_renderer replace_characters_in_range:range with_string:text];
        } else {
            [_emoji_text_renderer replace_characters_in_range:range with_string:text];
            [_accessoryview_textview setSelectedRange:NSMakeRange(range.location+text.length, 0)];
        }
        [self recalculate_textview_layout];
        __rentrant_lock = NO;
    }
	return NO;
}

-(void)recalculate_textview_layout{
    [_accessoryview_textview setNeedsLayout];
    [_accessoryview_textview layoutIfNeeded];
    
    int text_rows = [self text_rows];
    if (text_rows == 0) text_rows = 1;
    int textview_display_lines = text_rows > 3 ? 3 : text_rows;
	
    [UIView animateWithDuration:0.1f animations:^(){
        view_set_height(_accessoryview_textview, textview_display_lines * 25 + 6);
        view_set_y(_controlbar_mode_selection, _accessoryview_textview.frame.size.height);
		if (_accessoryview_root.constraints.count > 0) {
            ((NSLayoutConstraint*)[[_accessoryview_root constraints] objectAtIndex:0]).constant = _accessoryview_textview.frame.size.height + _controlbar_mode_selection.frame.size.height;
        }
        view_set_x(_done_button, _accessoryview_textview.frame.size.width);
        view_set_y(_done_button, _accessoryview_textview.frame.origin.y);
        view_set_width(_done_button, _accessoryview_root.frame.size.width-_accessoryview_textview.frame.size.width);
        view_set_height(_done_button, _accessoryview_textview.frame.size.height);
        view_set_height(_accessoryview_root, _accessoryview_textview.frame.size.height + _controlbar_mode_selection.frame.size.height);
        view_set_y(_bottom_border, _accessoryview_root.frame.size.height-_bottom_border.frame.size.height);
        
        [_accessoryview_root.superview layoutIfNeeded];
    } completion:NULL];
    
    if (text_rows > textview_display_lines) {
        [_accessoryview_textview scrollRangeToVisible:_accessoryview_textview.selectedRange];
    } else {
        [_accessoryview_textview setContentOffset:CGPointZero animated:NO];
    }
}


-(int)text_rows {
    return round( ([_emoji_text_renderer get_text_bounds_for_width:_accessoryview_textview.bounds.size.width].size.height - _accessoryview_textview.textContainerInset.top - _accessoryview_textview.textContainerInset.bottom) / _accessoryview_textview.font.lineHeight );
}

-(void)controlbar_option_textmode {
    _root_activaton_textview.inputView = NULL;
    _accessoryview_textview.inputView = NULL;
    [_root_activaton_textview reloadInputViews];
    [_accessoryview_textview reloadInputViews];
}

-(void)controlbar_option_recordmode {
    NSLog(@"record mode");
}

-(void)controlbar_option_emojimode {
	_root_activaton_textview.inputView = _emoji_keyboard.view;
	_accessoryview_textview.inputView = _emoji_keyboard.view;
	[_root_activaton_textview reloadInputViews];
    [_accessoryview_textview reloadInputViews];
	
	[_emoji_keyboard i_cons:[[ICEmojiTextureCache instance] get_all_emoji_names]];
}

-(void)toggle_native_control_ui:(BOOL)val {
    if (val) {
        [_root_activaton_textview becomeFirstResponder];
		[_accessoryview_textview becomeFirstResponder];
        [self controlbar_option_emojimode];
        if (_keyboard_mode == KeyboardMode_Closed || _keyboard_mode == KeyboardMode_OpenToClose) {
            _keyboard_mode = KeyboardMode_CloseToOpen;
        }
        
    } else {
        [_accessoryview_textview resignFirstResponder];
        [_root_activaton_textview resignFirstResponder];
        
        if (_keyboard_mode == KeyboardMode_Open || _keyboard_mode == KeyboardMode_CloseToOpen) {
            _keyboard_mode = KeyboardMode_OpenToClose;
        }
    }
}

-(void)load_message_json:(NSString *)messageJSON {
	[_emoji_text_renderer set_json:messageJSON];
	[self recalculate_textview_layout];
}

-(NSString*)out_message_json {
	return [_emoji_text_renderer get_json];
}

-(void)enqueue_button_press:(NSString*)name {
    [_enqueued_button_presses addObject:@{@"button":name}];
}

-(void)done_button_press {
    [[ICRootViewController context] enqueue_button_press:@"close"];
}

-(void)delete_button_pressed {
    NSRange selected_range = [_accessoryview_textview selectedRange];
    if (selected_range.length == 0 && selected_range.location > 0) {
        selected_range.location -= 1;
        selected_range.length = 1;
    }
    [self textView:_accessoryview_textview shouldChangeTextInRange:selected_range replacementText:@""];
}

-(NSString*)getc_input_button_presses {
    NSError *error;
    NSData *json_data = [NSJSONSerialization dataWithJSONObject:_enqueued_button_presses options:0 error:&error];
    [_enqueued_button_presses removeAllObjects];
    return [[NSString alloc] initWithData:json_data encoding:NSUTF8StringEncoding];
}

-(BOOL)prefersStatusBarHidden { return YES; }

@end