#import "SpecHelper.h"

// Ugh. Unfortunately layoutSubviews is never called when the view is not part of an application.
// Creating a window and making it key also doesn't work because that requires a UIApplication instance
// (I think) and our tests don't run as part of an application.
void setFrame(UIView *view, CGRect frame) {
    view.frame = frame;
    [view layoutSubviews];
}

