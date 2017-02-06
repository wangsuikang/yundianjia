//
//  YUNSegmentButton.h
//  Shops-iPhone
//
//  Created by Tsao Jiaxin on 15/7/17.
//  Copyright (c) 2015年 net.atyun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YUNSegmentButton : UIButton
/// icon所在的UIImageView
@property (nonatomic,weak) UIImageView *iconView;

/// icon对应的icon图标文件名
@property (nonatomic,copy) NSString *iconName;

- (instancetype)initWithFrame:(CGRect)frame icon:(NSString *)iconName;
@end
