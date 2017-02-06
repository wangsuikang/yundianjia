//
//  NSString+StringSize.m
//  UILabelDemo2
//
//  Created by ZSQ on 15-3-18.
//  Copyright (c) 2015年 ZSQ. All rights reserved.
//

#import "NSString+StringSize.h"

@implementation NSString (StringSize)

- (CGSize) sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGSize retSize;
    if ( [[[UIDevice currentDevice] systemVersion]  floatValue] < 7.0) {
        //iOS7之前使用这个方法
        retSize = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
    }
    else
    {
        //创建属性字典，用来保存字符串相关的属性
        NSMutableDictionary *attrDict = [NSMutableDictionary dictionary];
        // 在字典中设置字符串使用的字体。
        [attrDict setObject:font forKey:NSFontAttributeName];
        
        // iOS7以及之后的版本用这个方法
        retSize = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:attrDict context:nil].size;
    }
    
    return retSize;
}

@end
