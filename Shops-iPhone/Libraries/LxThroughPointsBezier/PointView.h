//
//  PointView.h
//  LxThroughPointsBezierDemo
//

#import <UIKit/UIKit.h>

@interface PointView : UIControl

+ (PointView *)aInstance:(UIColor *)color center:(CGPoint)point;

@property (nonatomic,copy) void (^dragCallBack)(PointView * pointView);

@end
