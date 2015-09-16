#import "ICButton.h"

@implementation Callback
@synthesize _target;
@synthesize _selector;
+(Callback*)cons_id:(id)target selector:(SEL)selector {
    Callback *rtv = [[Callback alloc] init];
    rtv._target = target;
    rtv._selector = selector;
    return rtv;
}
-(void)call {
	IMP imp = [_target methodForSelector:_selector];
	void (*func)(id, SEL) = (void *)imp;
	func(_target,_selector);
}
@end

@implementation ICButton {
    BOOL _is_touch_down;
    BOOL _is_just_pressed;
    Callback *_neutral_callback;
    Callback *_down_callback;
    Callback *_pressed_callback;
}

-(id)init {
    self = [super init];
    self.multipleTouchEnabled = NO;
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _is_touch_down = YES;
    [self proc_down];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _is_touch_down = NO;
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
	if (CGRectContainsPoint(self.bounds, touchLocation)) {
		_is_just_pressed = YES;
        [self proc_pressed];
	}
    [self proc_neutral];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    _is_touch_down = NO;
    [self proc_neutral];
}

-(BOOL)get_is_touch_down {
    return _is_touch_down;
}

-(BOOL)getc_is_just_pressed {
    BOOL rtv = _is_just_pressed;
    _is_just_pressed = NO;
    return rtv;
}

-(void)proc_neutral {
    [_neutral_callback call];
}
-(void)proc_down {
    [_down_callback call];
}
-(void)proc_pressed {
    [_pressed_callback call];
}

-(void)set_neutral:(Callback*)callback {
    _neutral_callback = callback;
}
-(void)set_down:(Callback*)callback {
    _down_callback = callback;
}
-(void)set_pressed:(Callback*)callback {
    _pressed_callback = callback;
}
@end


@implementation ICImageButton {
    UIImageView *_image;
    UIColor *_color_neutral;
    UIColor *_color_down;
}
-(void)set_image:(UIImage*)img {
    if (_image == NULL) {
        _image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:_image];
        _color_neutral = [UIColor colorWithRed:0.2 green:0.819 blue:0.803 alpha:1.0];
        _color_down = [UIColor colorWithRed:0.1 green:0.4 blue:0.4 alpha:1.0];
        [self proc_neutral];
    }
    [_image setImage:img];
}
-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [_image setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}
-(void)proc_neutral {
    [super proc_neutral];
    [_image setTintColor:_color_neutral];
}
-(void)proc_down {
    [super proc_down];
    [_image setTintColor:_color_down];
}
-(void)img_scale_x:(float)x y:(float)y {
    _image.transform = CGAffineTransformMakeScale(x,y);
}
-(void)set_color_neutral:(UIColor *)neutral down:(UIColor *)down {
    _color_neutral = neutral;
    _color_down = down;
    [self proc_neutral];
}
@end

@implementation ICLabelButton {
    UILabel *_label;
}
-(void)set_label:(NSString *)text {
    if (_label == NULL) {
        _label = [[UILabel alloc] initWithFrame:self.frame];
        [_label setFont:[UIFont systemFontOfSize:15]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_label];
        [self proc_neutral];
    }
    [_label setText:text];
}
-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [_label setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
}
-(void)proc_neutral {
    [super proc_neutral];
    [_label setTextColor:[UIColor colorWithRed:0.2 green:0.819 blue:0.803 alpha:1.0]];
}
-(void)proc_down {
    [super proc_down];
    [_label setTextColor:[UIColor colorWithRed:0.1 green:0.4 blue:0.4 alpha:1.0]];
}

@end
