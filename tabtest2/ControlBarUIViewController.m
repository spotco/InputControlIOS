#import "ControlBarUIViewController.h"

#define clampf(_val,_min,_max) (_val > _max ? _max : (_val < _min ? _min : _val))
float bezier_val_for_t(float p0, float p1, float p2, float p3, float t) {
	float cp0 = (1 - t)*(1 - t)*(1 - t);
	float cp1 = 3 * t * (1-t)*(1-t);
	float cp2 = 3 * t * t * (1 - t);
	float cp3 = t * t * t;
	return cp0 * p0 + cp1 * p1 + cp2 * p2 + cp3 * p3;
}

CGPoint bezier_point_for_t(CGPoint p0, CGPoint p1, CGPoint p2, CGPoint p3, float t) {
	return CGPointMake(
		bezier_val_for_t(p0.x, p1.x, p2.x, p3.x, t),
		bezier_val_for_t(p0.y, p1.y, p2.y, p3.y, t)
	);
}

typedef enum _KeyboardMode {
    KeyboardMode_Closed,
    KeyboardMode_Open,
    KeyboardMode_OpenToClose,
    KeyboardMode_CloseToOpen
} KeyboardMode;

typedef enum _ControlBarUIViewControllerMode {
    ControlBarUIViewControllerMode_Closed,
    ControlBarUIViewControllerMode_Open
} ControlBarUIViewControllerMode;

@implementation ControlBarUIViewController {
    UITextView *_root_activaton_textview;
    UIView *_accessoryview_root;
    
    UITextView *_accessoryview_textview;
    
    //NSString *_text_contents;

    //UIView *_custom_input_view_1;
    UIToolbar *_controlbar_mode_selection;
    
    CGRect _input_view_screen_rect;
    
    NSTimer *_update_timer;
    double _keyboard_animation_duration;
    double _keyboard_animation_t; //0 closed, _keyboard_aniation_duration open
    KeyboardMode _keyboard_mode;
    NSTimeInterval _last_update_time;
	
	ICEmojiKeyboard *_emoji_keyboard;
	ICEmojiTextRenderer *_emoji_text_renderer;
}

static ControlBarUIViewController *_context;
+(ControlBarUIViewController*)context { return _context; }
-(void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    _input_view_screen_rect = [value CGRectValue];
    if ([notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] != 0) {
        _keyboard_animation_duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue] * 2;
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
    NSLog(@"%@",rtv);
    return rtv;
}

-(void)viewDidAppear:(BOOL)animated {
    _context = self;
    _last_update_time = [NSDate timeIntervalSinceReferenceDate];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:NULL];
    
    _update_timer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(update) userInfo:NULL repeats:YES];
    _keyboard_mode = KeyboardMode_Closed;
    _keyboard_animation_duration = 0.5;
    
    [super viewDidAppear:animated];
    /*
    [self.view addSubview:((UnityAppController*)[UIApplication sharedApplication].delegate).unityView];
    */
    

    _root_activaton_textview = [[UITextView alloc] initWithFrame:CGRectMake(0,0,0,0)];
	
    _accessoryview_textview = [[UITextView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width - 60, 25)];
    _accessoryview_textview.textContainer.lineBreakMode = NSLineBreakByCharWrapping;
    [_accessoryview_textview setFont:[UIFont systemFontOfSize:20]];
    _accessoryview_textview.textContainer.lineFragmentPadding = 0;
    _accessoryview_textview.textContainerInset = UIEdgeInsetsZero;
    _accessoryview_textview.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
    
    [_accessoryview_textview setDelegate:self];
    [_root_activaton_textview setDelegate:self];
    
    _accessoryview_root = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 50)];
    _accessoryview_root.backgroundColor = [UIColor colorWithRed:0.99 green:0.99 blue:0.99 alpha:1.0];
    _accessoryview_root.clipsToBounds = YES;
    _accessoryview_root.autoresizesSubviews = NO;
    
    [_accessoryview_root addSubview:_accessoryview_textview];
    
    _root_activaton_textview.inputAccessoryView = _accessoryview_root;
    _accessoryview_textview.inputAccessoryView = _accessoryview_root;
    _root_activaton_textview.keyboardType = UIKeyboardTypeASCIICapable;
    _accessoryview_textview.keyboardType = UIKeyboardTypeASCIICapable;
    
    [self.view addSubview:_root_activaton_textview];
    
    _controlbar_mode_selection = [[UIToolbar alloc] init];
    _controlbar_mode_selection.frame = CGRectMake(0, 25, [UIScreen mainScreen].bounds.size.width, 25);
    _controlbar_mode_selection.backgroundColor = [UIColor colorWithRed:0.99 green:0.99 blue:0.99 alpha:1];
    _controlbar_mode_selection.barTintColor = [UIColor colorWithRed:0.99 green:0.99 blue:0.99 alpha:1];
    _controlbar_mode_selection.clipsToBounds = YES;
    
    [_accessoryview_root addSubview:_controlbar_mode_selection];
    [_controlbar_mode_selection setItems:@[
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(controlbar_option1)],
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(controlbar_option2)]
    ] animated:YES];
	
	_emoji_keyboard = [[ICEmojiKeyboard alloc] init];
	[_emoji_keyboard set_input_listener:self];
	
	_emoji_text_renderer = [[ICEmojiTextRenderer alloc] init];
	[_emoji_text_renderer set_textview:_accessoryview_textview];
    [_emoji_text_renderer replace_characters_in_range:NSMakeRange(0, 0) with_string:@""];
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

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([_root_activaton_textview isFirstResponder] && [_accessoryview_textview canBecomeFirstResponder]) {
        [_root_activaton_textview resignFirstResponder];
        [_accessoryview_textview becomeFirstResponder];
    }
    [_emoji_text_renderer replace_characters_in_range:range with_string:text];
    
    [self recalculate_textview_layout];
    [_accessoryview_textview setSelectedRange:NSMakeRange(range.location+text.length, 0)];
	return NO;
}

-(void)recalculate_textview_layout{
    [_accessoryview_textview setNeedsLayout];
    [_accessoryview_textview layoutIfNeeded];
    
    int text_rows = [self text_rows];
    int textview_display_lines = text_rows > 3 ? 3 : text_rows;

    [UIView animateWithDuration:0.1f animations:^(){
        _accessoryview_textview.frame = CGRectMake(0,0, _accessoryview_textview.frame.size.width, textview_display_lines * 25);
        _controlbar_mode_selection.frame = CGRectMake(0, textview_display_lines * 25, _controlbar_mode_selection.frame.size.width, _controlbar_mode_selection.frame.size.height);
        if (_accessoryview_root.constraints.count > 0) ((NSLayoutConstraint*)[[_accessoryview_root constraints] objectAtIndex:0]).constant = _accessoryview_textview.frame.size.height + 25;
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

-(void)controlbar_option1 {
    _root_activaton_textview.inputView = NULL;
    _accessoryview_textview.inputView = NULL;
    [_root_activaton_textview reloadInputViews];
    [_accessoryview_textview reloadInputViews];
}

-(void)controlbar_option2 {
	_root_activaton_textview.inputView = _emoji_keyboard.view;
	_accessoryview_textview.inputView = _emoji_keyboard.view;
	[_root_activaton_textview reloadInputViews];
    [_accessoryview_textview reloadInputViews];
	
	[_emoji_keyboard i_cons:@[
		[ICEmojiEntry cons_name:@"test1" url:@"http://spotcos.com/et/highfive.png"],
		[ICEmojiEntry cons_name:@"test2" url:@"http://spotcos.com/et/highfive.png"],
		[ICEmojiEntry cons_name:@"test3" url:@"http://spotcos.com/et/highfive.png"],
		[ICEmojiEntry cons_name:@"test4" url:@"http://spotcos.com/et/highfive.png"],
		[ICEmojiEntry cons_name:@"test5" url:@"http://spotcos.com/et/highfive.png"],
		[ICEmojiEntry cons_name:@"test6" url:@"http://spotcos.com/et/highfive.png"],
		[ICEmojiEntry cons_name:@"test7" url:@"http://spotcos.com/et/highfive.png"],
		[ICEmojiEntry cons_name:@"test8" url:@"http://spotcos.com/et/highfive.png"],
		[ICEmojiEntry cons_name:@"test9" url:@"http://spotcos.com/et/highfive.png"]
	]];
}

-(void)toggle_native_control_ui:(BOOL)val {
    if (val) {
        [_root_activaton_textview becomeFirstResponder];
        
        if (_keyboard_mode == KeyboardMode_Closed || _keyboard_mode == KeyboardMode_OpenToClose) {
            _keyboard_mode = KeyboardMode_CloseToOpen;
            _keyboard_animation_t = 0;
        }
        
    } else {
        [_accessoryview_textview resignFirstResponder];
        [_root_activaton_textview resignFirstResponder];
        
        if (_keyboard_mode == KeyboardMode_Open || _keyboard_mode == KeyboardMode_CloseToOpen) {
            _keyboard_mode = KeyboardMode_OpenToClose;
            _keyboard_animation_t = _keyboard_animation_duration;
        }
    }
}

-(void)load_message_json:(NSString *)messageJSON {
    NSLog(@"load_message_json:%@",messageJSON);
}

-(BOOL)prefersStatusBarHidden { return YES; }
/*
-(BOOL)canBecomeFirstResponder{ return YES; }
-(UIView *)inputAccessoryView{ return _accessoryview_root; }
*/
@end
