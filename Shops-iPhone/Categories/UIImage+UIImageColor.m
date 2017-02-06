//
//  UIImage+UIImageColor.m
//  Shops-iPhone
//
//  Created by xxy on 15/10/29.
//  Copyright © 2015年 net.atyun. All rights reserved.
//

#import "UIImage+UIImageColor.h"

@implementation UIImage (UIImageColor)

+ (UIImage *)buttonImageFromColor:(UIColor *)color{
    CGRect rect = CGRectMake(0, 0, kScreenWidth, kNavTabBarHeight);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
