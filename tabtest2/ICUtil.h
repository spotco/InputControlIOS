#import <UIKit/UIKit.h>

#define clampf(_val,_min,_max) (_val > _max ? _max : (_val < _min ? _min : _val))
float bezier_val_for_t(float p0, float p1, float p2, float p3, float t);
CGPoint bezier_point_for_t(CGPoint p0, CGPoint p1, CGPoint p2, CGPoint p3, float t);

void view_set_x(UIView *view, float x);
void view_set_y(UIView *view, float y);
void view_set_width(UIView *view, float width);
void view_set_height(UIView *view, float height);