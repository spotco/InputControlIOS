#import "ICUtil.h"

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

void view_set_x(UIView *view, float x) {
    view.frame = CGRectMake(
        x,
        view.frame.origin.y,
        view.frame.size.width,
        view.frame.size.height
    );
}

void view_set_y(UIView *view, float y) {
    view.frame = CGRectMake(
        view.frame.origin.x,
        y,
        view.frame.size.width,
        view.frame.size.height
    );
}

void view_set_width(UIView *view, float width) {
    view.frame = CGRectMake(
        view.frame.origin.x,
        view.frame.origin.y,
        width,
        view.frame.size.height
    );
}


void view_set_height(UIView *view, float height) {
    view.frame = CGRectMake(
        view.frame.origin.x,
        view.frame.origin.y,
        view.frame.size.width,
        height
    );
}

