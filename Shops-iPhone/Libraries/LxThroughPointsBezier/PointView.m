//
//  PointView.m
//  LxThroughPointsBezierDemo
//

#import "PointView.h"

static CGFloat const RADIUS = 5;

@implementation PointView

+ (PointView *)aInstance:(UIColor *)color center:(CGPoint)point
{
    PointView * aInstance = [[self alloc] initWithFrame:(CGRect){point, CGSizeMake(RADIUS , RADIUS)}];
    aInstance.layer.cornerRadius = RADIUS / 2;
    aInstance.layer.masksToBounds = YES;
    aInstance.backgroundColor = color;
//    [aInstance addTarget:aInstance action:@selector(touchDragInside:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    
    return aInstance;
}

- (void)touchDragInside:(PointView *)pointView withEvent:(UIEvent *)event
{
    pointView.center = [[[event allTouches] anyObject] locationInView:self.superview];
    
    if (self.dragCallBack) {
        self.dragCallBack(self);
    }
}

@end
