//
//  UIColor+JKColor.h
//  ToolsProject
//
//  Created by Jonkey on 15/6/15.
//  Copyright (c) 2015年 UMS. All rights reserved.
//

#import <UIKit/UIKit.h>

#undef  RGBCOLOR
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

#undef  RGBACOLOR
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#undef	HEX_RGB
#define HEX_RGB(V)		[UIColor colorWithRGBHex:V]

@interface UIColor (JKColor)

+ (UIColor *)colorWithRGBHex:(UInt32)hex;
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

+ (UIColor *)colorWithCssName:(NSString *)cssColorName;

+ (UIColor *)bgColor_nav;
+ (UIColor *)bgColor_view;

@end
