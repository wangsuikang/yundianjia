//
//  SplitLineView.m
//  QiuYiGua
//
//  Created by rujax on 2013-07-15.
//  Copyright (c) 2013年 net.atyun. All rights reserved.
//

#import "SplitLineView.h"

@interface SplitLineView()

@end

@implementation SplitLineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = self.color ? self.color : [UIColor lightGrayColor];
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    
//    CGContextMoveToPoint(ctx, self.startPoint.x, self.startPoint.y);
//    CGContextAddLineToPoint(ctx, self.endPoint.x, self.endPoint.y);
//    
//    CGContextSetLineWidth(ctx, rect.size.height);
//    
//    CGFloat al = (self.alpha && self.alpha <= 1.0 && self.alpha >= 0.0) ? self.alpha : 1.0;
//    CGFloat r = (self.red && self.red <= 255.0 && self.red >= 0.0) ? self.red / 255.0 : 0.945;
//    CGFloat g = (self.green && self.green <= 255.0 && self.green >= 0.0) ? self.green / 255.0 : 0.945;
//    CGFloat b = (self.blue && self.blue <= 255.0 && self.blue >= 0.0) ? self.blue / 255.0 : 0.945;
//    
//    YunLog(@"red = %f, green = %f, blue = %f, alpha = %f", r, g, b, al);
//
//    CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
//
//    CGContextStrokePath(ctx);
//}

//- (void)drawRect:(CGRect)rect
//{
//    UIGraphicsBeginImageContext(rect.size);
//    
//    [self.image drawInRect:rect];
//    
//    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
//    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    
//    CGContextSetLineWidth(ctx, 1.0f);
//    CGContextMoveToPoint(ctx, rect.origin.x, rect.origin.y);
//    CGContextAddLineToPoint(ctx, rect.origin.x + rect.size.width, rect.origin.y);
//    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
//    CGContextStrokePath(ctx);
//    
//    self.image = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//}

@end
