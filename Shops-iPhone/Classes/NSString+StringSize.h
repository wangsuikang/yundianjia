//
//  NSString+StringSize.h
//  UILabelDemo2
//
//  Created by ZSQ on 15-3-18.
//  Copyright (c) 2015年 ZSQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (StringSize)

//根据不同的版本用响应的方法计算字符串的大小
// 参数1: 字符串使用的字体
// 参数2: 字符串限制的范围
// 参数3: 换行模式
- (CGSize) sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end
