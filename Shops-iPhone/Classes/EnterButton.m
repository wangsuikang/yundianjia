//
//  EnterButton.m
//  Shops-iPhone
//
//  Created by xxy on 15/6/12.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import "EnterButton.h"

@implementation EnterButton

// 用户点击按钮，按钮会调用这个方法处理高亮状态
// 重写这个方法，取消按钮的高亮状态
- (void)setHighlighted:(BOOL)highlighted
{
    // 在父类的setHighlighted处理了高亮状态(图片变暗)
     [super setHighlighted:highlighted];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
