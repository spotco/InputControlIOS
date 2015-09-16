#import <UIKit/UIKit.h>

@interface Callback : NSObject
+(Callback*)cons_id:(id)target selector:(SEL)selector;
@property(readwrite,strong) id _target;
@property(readwrite,assign) SEL _selector;
@end

@interface ICButton : UIView
-(BOOL)get_is_touch_down;
-(BOOL)getc_is_just_pressed;

-(void)set_pressed:(Callback*)callback;

-(void)proc_neutral;
-(void)proc_down;
-(void)proc_pressed;
@end

@interface ICImageButton : ICButton
-(void)set_image:(UIImage*)img;
-(void)img_scale_x:(float)x y:(float)y;
-(void)set_color_neutral:(UIColor*)neutral down:(UIColor*)down;
@end

@interface ICLabelButton : ICButton
-(void)set_label:(NSString*)text;
@end