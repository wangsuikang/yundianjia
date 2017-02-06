//
//  UIView+Tools.h
//  Shops-iPhone
//
//  Created by rujax on 14-9-26.
//  Copyright (c) 2014年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Tools)

// 添加边框
typedef NS_ENUM(NSInteger, AddBorderDirection) {
    AddBorderDirectionTop       = 1 << 0,
    AddBorderDirectionRight     = 1 << 1,
    AddBorderDirectionBottom    = 1 << 2,
    AddBorderDirectionLeft      = 1 << 3
};

- (void)addBorderWithDirection:(AddBorderDirection)direction;
- (void)addBorderWithDirection:(AddBorderDirection)direction color:(UIColor *)color border:(CGFloat)border indent:(CGFloat)indent;

@end
